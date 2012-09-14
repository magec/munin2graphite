require File.expand_path(File.join(File.dirname(__FILE__),"/test_init"))

class TestMuninGraph < Test::Unit::TestCase

  def setup
    Munin2Graphite::Config.config_file = TEST_CONFIG_FILE
    @munin = Munin::Node.new(Munin2Graphite::Config["munin_hostname"],Munin2Graphite::Config["munin_port"])
    @simple_graph = MuninGraph.new(<<END
graph_title ACPI Thermal zone temperatures
graph_vlabel Celcius
graph_category sensors
graph_info This graph shows the temperature in different ACPI Thermal zones.  If there is only one it will usually be the case temperature.
THM0.label THM0
THM0.colour black
THM1.label THM1
END
)
    @apache_graph = MuninGraph.new(<<END
graph_title Apache accesses
graph_args --base 1000
graph_vlabel accesses / ${graph_period}
graph_category apache
accesses80.label port 80
accesses80.type DERIVE
accesses80.max 1000000
accesses80.min 0
accesses80.info The number of accesses (pages and other items served) globaly on the Apache server
END
)

    @processes_graph = MuninGraph.new(<<END
graph_title Apache processes
graph_args --base 1000 -l 0
graph_category apache
graph_order busy80 idle80 
graph_vlabel processes
graph_total total
busy80.label busy servers 80
busy80.draw AREA
busy80.colour 33cc00
idle80.label idle servers 80
idle80.draw STACK
idle80.colour 0033ff
free80.label free slots 80
free80.draw STACK
free80.colour ccff00
END
)    

    @log_graph = MuninGraph.new(<<END
config iostat_ios
graph_title IO Service time
graph_args --base 1000 --logarithmic
graph_category disk
graph_vlabel seconds
graph_info For each applicable disk device this plugin shows the latency (or delay) for I/O operations on that disk device.  The delay is in part made up of waiting for the disk to flush the data, and if data arrives at the disk faster than it can read or write it then the delay time will include the time needed for waiting in the queue.
dev104_0_rtime.label cciss/c0d0 read
dev104_0_rtime.type GAUGE
dev104_0_rtime.draw LINE2
dev104_0_rtime.cdef dev104_0_rtime,1000,/
dev104_0_wtime.label cciss/c0d0 write
dev104_0_wtime.type GAUGE
dev104_0_wtime.draw LINE2
dev104_0_wtime.cdef dev104_0_wtime,1000,/
dev104_16_rtime.label cciss/c0d1 read
dev104_16_rtime.type GAUGE
dev104_16_rtime.draw LINE2
dev104_16_rtime.cdef dev104_16_rtime,1000,/
dev104_16_wtime.label cciss/c0d1 write
dev104_16_wtime.type GAUGE
dev104_16_wtime.draw LINE2
dev104_16_wtime.cdef dev104_16_wtime,1000,/
END
)
    @simple_graph.config = Munin2Graphite::Config.merge({ 
                                                                     "metric_prefix" => "test.frontends.linux",
                                                                     "category" => "sensors", 
                                                                     "hostname" => "myhost",
                                                                     "metric" => "acpi"}
                                                                   )
    @apache_graph.config = Munin2Graphite::Config.merge({ "metric_prefix" => "test.frontends.linux",
                                                          "category" => "apache",
                                                          "hostname" => "myhost",
                                                          "metric" => "apache_accesses"
                                                        })

    @processes_graph.config = Munin2Graphite::Config.merge({ 
                                                             "metric_prefix" => "test.frontends.linux",
                                                             "category" => "apache",
                                                             "hostname" => "myhost",
                                                             "metric" => "apache_processes"
                                                           })
    @log_graph.config = Munin2Graphite::Config.merge({
                                                       "metric_prefix" => "test.frontends.linux",
                                                       "category" => "apache",
                                                       "hostname" => "myhost",
                                                       "metric" => "iostat_ios"
                                                     })
  end

  def test_get_title
    root = @simple_graph.root
    assert_equal root.children.length, 6
  end

  def test_compilation_on_simple_graph
    root = @simple_graph.root
    root.compile
    field_declarations = root.children_of_class(FieldDeclarationNode)
    assert_equal field_declarations.first.compile,"alias(test.frontends.linux.myhost.sensors.acpi.THM0,'THM0')"
    assert_equal root.graph_properties[:vtitle], "Celcius"
    assert_equal root.graph_properties[:title], "ACPI Thermal zone temperatures"
  end

  def test_compilation_on_derivative_graph
    root = @apache_graph.root
    field_declarations = root.children_of_class(FieldDeclarationNode)
    root.compile
    assert_equal field_declarations.first.compile,"alias(scaleToSeconds(nonNegativeDerivative(test.frontends.linux.myhost.apache.apache_accesses.accesses80),1),'port 80')"
    assert_equal root.graph_properties[:yMax], 1000000
    assert_equal root.graph_properties[:yMin], 0
    assert_equal root.properties[:base] , 1000
    assert_equal root.graph_properties[:title], "Apache accesses"
  end

  def test_children_of_class
    root = @simple_graph.root
    assert_equal root.children_of_class(GlobalDeclarationNode).length, 4
    field_declarations = root.children_of_class(FieldDeclarationNode)
#   puts field_declarations.map(&:properties).inspect
    assert_equal field_declarations.length,2
    assert_equal field_declarations.first.children.length,2
    assert_equal field_declarations[1].children.length,1
  end

  def test_stacked_graph    
    root = @processes_graph.root
    @processes_graph.root.compile
    stacked = false
    root.targets.each do |target|
      if target.compile =~ /stacked/
        stacked = true
      end
    end
    assert_equal stacked,true

  end

  def test_variable_substitution
    @apache_graph.root.compile
    assert_nil  @apache_graph.root.url =~ /graph_period/
  end

  def test_random_colors
    root = @processes_graph.root
    @processes_graph.root.compile
    assert_equal @processes_graph.root.graph_properties[:colorList].first , "#33cc00"
  end

  def test_logarithmic_graph
    root = @log_graph.root
    root.compile
    root.targets.each do |target|
#      assert_not_nil target.compile =~ /log/
    end
  end

  def test_global_attributes_can_appear_wherever
    graph = MuninGraph.new(<<END
graph_title Load average
graph_args --base 1000 -l 0
graph_vlabel load
graph_scale no
graph_category system
load.label load
graph_info The load average of the machine describes how many processes are in the run-queue (scheduled to run "immediately").
load.info 5 minute load average
END
)
    graph.config = Munin2Graphite::Config.merge({ 'metric' => "load",'hostname' => "localhost"})
    graph.root.url
  end

  def test_host_name_changed
    graph = MuninGraph.new(<<END
host_name Firewalls
graph_title Load average
graph_args --base 1000 -l 0
graph_vlabel load
graph_scale no
graph_category system
load.label load
graph_info The load average of the machine describes how many processes are in the run-queue (scheduled to run "immediately").
load.info 5 minute load average
END
)
    graph.config = Munin2Graphite::Config.merge({ 'metric' => "load",'hostname' => "localhost"})    
    graph.root.url
    assert_equal graph.root.properties['hostname'] , "Firewalls"
  end


  def test_multi_line
    graph = MuninGraph.new(<<END                                                                                                                            
graph_order down up
graph_title eth2 traffic
graph_args --base 1000
  graph_vlabel bits in (-) / out (+) per ${graph_period}
graph_category network
graph_info This graph shows the traffic of the eth2 network interface. Please note that the traffic is shown in bits per second, not bytes. IMPORTANT: On 32 bit systems the data source for this plugin uses 32bit counters, which makes the plugin unreliable and unsuitable for most 100Mb (or faster) interfaces, where traffic is expected to exceed 50Mbps over a 5 minute period.  This means that this plugin is unsuitable for most 32 bit production environments. To avoid this problem, use the ip_ plugin instead.  There should be no problems on 64 bit systems running 64 bit kernels.
down.label received
down.type COUNTER
down.graph no
down.cdef down,8,*
up.label bps
up.type COUNTER
up.negative down
up.cdef up,8,*
up.max 1000000000
up.info Traffic of the eth2 interface. Maximum speed is 1000 Mbps.
down.max 1000000000
END
)
    graph.config = Munin2Graphite::Config.merge({ 'metric' => "load",'hostname' => "localhost"})
    graph.root.compile
    color_list = graph.root.graph_properties[:colorList]
    assert_equal color_list.first , color_list[1] # Thew should be drawn with the same color
    assert_match graph.root.url , /scale\(scale\(scaleToSeconds\(nonNegativeDerivative\(test.frontends.linux.localhost.network.load.down\),1\),8\)/
    assert_equal graph.root.children_of_class(FieldDeclarationNode).length , 2
     graph.root.url
  end

  def test_network_graph
    graph = MuninGraph.new(<<END
host_name Switxos
graph_category switch
graph_title One switck
graph_args --base 1000
graph_vlabel Errors in (G) / out (B) per ${graph_period}
fe_0_1_errors_in.label Errors IN
fe_0_1_errors_in.draw LINE1
fe_0_1_errors_in.type DERIVE
fe_0_1_errors_in.cdef fe_0_1_errors_in,8,*
fe_0_1_errors_in.max 2000000000
fe_0_1_errors_in.min 0
fe_0_1_errors_out.label Errors OUT
fe_0_1_errors_out.draw LINE1
fe_0_1_errors_out.type DERIVE
fe_0_1_errors_out.cdef fe_0_1_errors_out,8,*
fe_0_1_errors_out.max 2000000000
fe_0_1_errors_out.min 0
fe_0_2_errors_in.label Errors IN
fe_0_2_errors_in.draw LINE1
fe_0_2_errors_in.type DERIVE
fe_0_2_errors_in.cdef fe_0_2_errors_in,8,*
fe_0_2_errors_in.max 2000000000
fe_0_2_errors_in.min 0
fe_0_2_errors_out.label Errors OUT
fe_0_2_errors_out.draw LINE1
fe_0_2_errors_out.type DERIVE
fe_0_2_errors_out.cdef fe_0_2_errors_out,8,*
fe_0_2_errors_out.max 2000000000
fe_0_2_errors_out.min 0
fe_0_4_errors_in.label Errors IN
fe_0_4_errors_in.draw LINE1
fe_0_4_errors_in.type DERIVE
fe_0_4_errors_in.cdef fe_0_4_errors_in,8,*
fe_0_4_errors_in.max 2000000000
fe_0_4_errors_in.min 0
fe_0_4_errors_out.label Errors OUT
fe_0_4_errors_out.draw LINE1
fe_0_4_errors_out.type DERIVE
fe_0_4_errors_out.cdef fe_0_4_errors_out,8,*
fe_0_4_errors_out.max 2000000000
fe_0_4_errors_out.min 0
END
)
    graph.config = Munin2Graphite::Config.merge({ 'metric' => "load",'hostname' => "localhost"})
    graph.root.compile
    assert_equal graph.root.targets.length, 6
    
  end


  def test_negative_graphs
    graph = MuninGraph.new(<<END
graph_order down up
graph_title eth0 traffic
graph_args --base 1000
graph_vlabel bits in (-) / out (+) per ${graph_period}
graph_category network
graph_info This graph shows the traffic of the eth0 network interface. Please note that the traffic is shown in bits per second, not bytes. IMPORTANT: On 32 bit systems the data source for this plugin uses 32bit counters, which makes the plugin unreliable and unsuitable for most 100Mb (or faster) interfaces, where traffic is expected to exceed 50Mbps over a 5 minute period.  This means that this plugin is unsuitable for most 32 bit production environments. To avoid this problem, use the ip_ plugin instead.  There should be no problems on 64 bit systems running 64 bit kernels.
down.label received
down.type COUNTER
down.graph no
down.cdef down,8,*
up.label bps
up.type COUNTER
up.negative down
up.cdef up,8,*
up.max 1000000000
up.info Traffic of the eth0 interface. Maximum speed is 1000 Mbps.
down.max 1000000000
END
)
    graph.config = Munin2Graphite::Config.merge({ "graphite_user" => "testing",'metric' => "if_eth0",'hostname' => "test"})
    graph.root.compile
    assert_not_match graph.root.url, /received/
  end

  def test_network
    graph = MuninGraph.new(<<END
graph_category gtw.gtw4
graph_title gtw4
graph_info Model: 7206VXR Firmware: 12.2(15)T8
graph_args --base 1000
graph_vlabel Octets in (G) / out (B) per ${graph_period}
GigabitEthernet0_2_octets_in.label Conn
GigabitEthernet0_2_octets_in.negative GigabitEthernet0_2_octets_out
GigabitEthernet0_2_octets_in.draw LINE1
GigabitEthernet0_2_octets_in.type DERIVE
GigabitEthernet0_2_octets_in.cdef GigabitEthernet0_2_octets_in,8,*
GigabitEthernet0_2_octets_in.max 2000000000
GigabitEthernet0_2_octets_in.min 0
GigabitEthernet0_2_octets_out.label Conn
GigabitEthernet0_2_octets_out.draw LINE1
GigabitEthernet0_2_octets_out.type DERIVE
GigabitEthernet0_2_octets_out.cdef GigabitEthernet0_2_octets_out,8,*
GigabitEthernet0_2_octets_out.max 2000000000
GigabitEthernet0_2_octets_out.min 0
FastEthernet1_0_octets_in.label VLAN Internet - IN
FastEthernet1_0_octets_in.negative FastEthernet1_0_octets_out
FastEthernet1_0_octets_in.draw LINE1
FastEthernet1_0_octets_in.type DERIVE
FastEthernet1_0_octets_in.cdef FastEthernet1_0_octets_in,8,*
FastEthernet1_0_octets_in.max 2000000000
FastEthernet1_0_octets_in.min 0
FastEthernet1_0_octets_out.label VLAN Internet - OUT
FastEthernet1_0_octets_out.draw LINE1
FastEthernet1_0_octets_out.type DERIVE
FastEthernet1_0_octets_out.cdef FastEthernet1_0_octets_out,8,*
FastEthernet1_0_octets_out.max 2000000000
FastEthernet1_0_octets_out.min 0
FastEthernet1_1_octets_in.label FW
FastEthernet1_1_octets_in.negative FastEthernet1_1_octets_out
FastEthernet1_1_octets_in.draw LINE1
FastEthernet1_1_octets_in.type DERIVE
FastEthernet1_1_octets_in.cdef FastEthernet1_1_octets_in,8,*
FastEthernet1_1_octets_in.max 2000000000
FastEthernet1_1_octets_in.min 0
FastEthernet1_1_octets_out.label FW
FastEthernet1_1_octets_out.draw LINE1
FastEthernet1_1_octets_out.type DERIVE
FastEthernet1_1_octets_out.cdef FastEthernet1_1_octets_out,8,*
FastEthernet1_1_octets_out.max 2000000000
FastEthernet1_1_octets_out.min 0
END
                           )
    graph.config = Munin2Graphite::Config.merge({ "graphite_prefix" => "","munin_nodes" => "routers", "graphite_user" => "network",'metric' => "snmp_routers_gtw_gtw4_octets",'hostname' => "routers"})
    graph.root.compile
    assert_not_match graph.root.url, /received/
    assert_not_match graph.root.url, /\.\./
  end


end
