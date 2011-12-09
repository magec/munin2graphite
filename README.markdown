munin2graphite
===============

Munin2graphite is a munin-node to graphite translator. It works as a daemon that connects to a [munin-node](http://munin-monitoring.org/wiki/munin-node), and translates the data and the graphics into [carbon/graphite](http://graphite.wikidot.com/).

Installing
----------

To install munin2graphite you need a working ruby virtual machine with rubygems installed. Once you've got that, It's as easy as

    gem install munin2graphite
    
Configuring
------------

Munin2graphite can be used to post data to graphite from any number of munin nodes you want. The idea is simple, there is bunch of workers that periodically ask for metrics to their munin-nodes and then post that data to carbon. Also, every time the daemon is run, the available graphs from the munin nodes are read, translated and posted into graphite as well.

## Workers
You can either choose to use workers with different configuration or configure everything as global in the config file. A worker implies a new thread of execution with different configuration. Note that if you don't rewrite a given value on the worker, the one in the global config will be used.

## Config Example
Imagine, for example, that we have two munin-nodes in two different servers (munin-node1.example.com,munin-node2.example.com). Let's say that one munin node has, in turn 2 nodes configured on it and the other just one (node1.munin-node1.example.com and node2.munin-node1.example.com). We also have one graphite server and one carbon server (carbon.example.com and graphite.example.com), they can be on the same machine on in a different one. A valid config file for this would be:

    # Log config
    # log: The logfile, STDOUT if stdout is needed
    # log_level: Either DEBUG, INFO or WARN
    log=/var/log/munin2graphite
    log_level=INFO
    
    # Carbon backend
    # This has to point to the carbon backend to submit metrics
    carbon_hostname=carbon.example.com
    carbon_port=2003
    
    # Graphite endpoint
    # This is needed to send graph data to graphite
    graphite_endpoint=http://graphite.example.com/
    
    # User and password of the graphite web UI
    graphite_user=test
    graphite_password=secret

    # This is the prefix you want the on metrics
    graphite_metric_prefix=test.server
    
    # The prefix you want in the graphics, note that in the UI the grapichs are shown under the user name, so the user name is also added prfixed
    # to this prefix. That's why conveniently, I used 'test' (the user name) in the metric prefix
    graphite_graph_prefix=server
    
    
    # The period for sending the metrics
    # its format is the one of rufus-scheduler    
    scheduler_metrics_period=1m
    
    # The munin node hostname and its port
    munin_hostname=localhost
    munin_port=4949
    
    # Apart from the global configuration, you can define workers so a new thread is opened with the new configuration,
    # this is particulary useful when you have a single munin-node with several nodes configured and want to send different graphs
    # with different prefixes
    [node1.munin-node1]
    munin_hostname=munin-node1.example.com
    nodes=node1

    [node2.munin-node1]
    munin_hostname=munin-node1.example.com
    nodes=node2
    
    [munin-node2]
    munin_hostname=munin-node1.example.com

Running it
-----------
You can run it either as a daemon or as an executable. To run it as an executable, just call it with the config file. 

    munin2graphite config.conf

There is also a daemon version, bassically the same thing but wrapped up with the daemons gem. Its usage is as follows. By default the config file location will be /etc/munin2graphite/munin2graphite.conf. This daemon also supports to be run from /etc/init.d by means of a symbolic link.


    Usage: munin-graphite.rb <command> <options> -- <application options>
    
    * where <command> is one of:
      start         start an instance of the application
      stop          stop all instances of the application
      restart       stop all instances and restart them afterwards
      reload        send a SIGHUP to all instances of the application
      run           start the application and stay on top
      zap           set the application to a stopped state
      status        show status (PID) of application instances
                  
    * and where <options> may contain several of the following:
                  
      -t, --ontop                      Stay on top (does not daemonize)
      -f, --force                      Force operation
      -n, --no_wait                    Do not wait for processes to stop
                             
    Common options:
      -h, --help                       Show this message
          --version                    Show version

Contributing to munin2graphite
------------------------------- 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
-----------

Copyright (c) 2011 Jose Fernandez (magec). See LICENSE.txt for
further details.

