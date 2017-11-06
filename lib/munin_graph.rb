require 'ast_node'
require 'graphite'
#
# Author:: Jose Fernandez (@magec)
# Copyright:: Copyright (c) 2011 UOC (Universitat Oberta de Catalunya)
# License:: GNU General Public License version 2 or later
#
# This program and entire repository is free software; you can
# redistribute it and/or modify it under the terms of the GNU
# General Public License as published by the Free Software
# Foundation; either version 2 of the License, or any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA


##
# This class allows the transformation between graphite and munin config. It constructs an AST parsing the munin config information and
# outputs a valid graphic in graphite url format
# Jose Fernandez 2011
#
class MuninGraph

  def self.graph_for(config)
    MuninGraph.new(config)
  end

  def initialize(config)
    @raw_config = config
    parse_config
  end

  def config=(config)
    @config = config
    self.root.config = config
  end

  def to_graphite
    graph = Graphite::MyGraph.new
    self.root.compile
    graph.url = self.root.url
    self.root.properties[:category] ||= "other"
    
    if @config["graphite_prefix"] == "" || !@config["graphite_prefix"]  && @config["graphite_graph_prefix"] && @config["graphite_graph_prefix"] != ""
      puts "DEPRECATION WARNING: parameter graphite_graph_prefix is not used anymore, please use graphite_prefix instead."
      @config["graphite_prefix"] =  @config["graphite_graph_prefix"]
    end

    graph.name = "#{@config["hostname"]}.#{self.root.properties["category"]}.#{self.root.properties["metric"]}"
    graph.name = "#{@config["graphite_prefix"]}.#{graph.name}" if @config["graphite_prefix"] && @config["graphite_prefix"] != "" 
    return graph
  end

  def to_gdash
    self.root.compile
    self.root.to_gdash
  end

  attr_reader :root
  
  # This array of hashes will be used to match what kind of line we are dealing with and 
  # to know the corresponding ast node class
  TOKENS = [
            {:matcher => /^graph_title .*/, :klass => GraphTitleGlobalDeclarationNode},
            {:matcher => /^create_args .*/, :klass => CreateArgsGlobalDeclarationNode},
            {:matcher => /^graph_args .*/, :klass => GraphArgsGlobalDeclarationNode},
            {:matcher => /^graph_category .*/, :klass => GraphCategoryGlobalDeclarationNode},
            {:matcher => /^graph_info .*/, :klass => GraphInfoGlobalDeclarationNode},
            {:matcher => /^graph_order .*/, :klass => GraphOrderGlobalDeclarationNode},
            {:matcher => /^graph_vlabel .*/, :klass => GraphVLabelGlobalDeclarationNode},
            {:matcher => /^graph_total .*/, :klass => GraphTotalGlobalDeclarationNode},
            {:matcher => /^graph_scale .*/, :klass => GraphScaleGlobalDeclarationNode},
            {:matcher => /^graph .*/, :klass => GraphGlobalDeclarationNode},
            {:matcher => /^host_name .*/, :klass => HostNameGlobalDeclarationNode},
            {:matcher => /^update .*/, :klass => UpdateGlobalDeclarationNode},
            {:matcher => /^graph_period .*/, :klass => GraphPeriodGlobalDeclarationNode},
            {:matcher => /^graph_vtitle .*/, :klass => GraphVTitleGlobalDeclarationNode},
            {:matcher => /^service_order .*/, :klass => ServiceOrderGlobalDeclarationNode},
            {:matcher => /^graph_width .*/, :klass => GraphWidthGlobalDeclarationNode},
            {:matcher => /^graph_height .*/, :klass => GraphHeightGlobalDeclarationNode},
            {:matcher => /^graph_printfformat .*/, :klass => GraphPrintFormatGlobalDeclarationNode},
            {:matcher => /([\w]+)\.label\ .*$/,:klass => LabelFieldPropertyNode},
            {:matcher => /([\w]+)\.cdef\ .*$/,:klass => CDefFieldPropertyNode},
            {:matcher => /([\w]+)\.draw\ .*$/,:klass => DrawFieldPropertyNode},
            {:matcher => /([\w]+)\.graph\ .*$/,:klass => GraphFieldPropertyNode},
            {:matcher => /([\w]+)\.info\ .*$/,:klass => InfoFieldPropertyNode},
            {:matcher => /([\w]+)\.extinfo\ .*$/,:klass => ExtInfoFieldPropertyNode},
            {:matcher => /([\w]+)\.max\ .*$/,:klass => MaxFieldPropertyNode},
            {:matcher => /([\w]+)\.min\ .*$/,:klass => MinFieldPropertyNode},
            {:matcher => /([\w]+)\.negative\ .*$/,:klass => NegativeFieldPropertyNode},
            {:matcher => /([\w]+)\.type\ .*$/,:klass => TypeFieldPropertyNode},
            {:matcher => /([\w]+)\.warning\ .*$/,:klass => WarningFieldPropertyNode},
            {:matcher => /([\w]+)\.critical\ .*$/,:klass => CriticalFieldPropertyNode},
            {:matcher => /([\w]+)\.colour\ .*$/,:klass => ColourFieldPropertyNode},
            {:matcher => /([\w]+)\.skipdraw\ .*$/,:klass => SkipDrawFieldPropertyNode},
            {:matcher => /([\w]+)\.sum\ .*$/,:klass => SumFieldPropertyNode},
            {:matcher => /([\w]+)\.stack\ .*$/,:klass => StackFieldPropertyNode},
            {:matcher => /([\w]+)\.linevalue\[:color\[:label\]\]\ .*$/,:klass => LineValueFieldPropertyNode},
            {:matcher => /([\w]+)\.oldname\ .*$/,:klass => OldNameFieldPropertyNode},
            {:matcher => /([\w]+)\.value\ .*$/,:klass => ValueFieldPropertyNode} 
     ]

   def parse_config
     @root = ASTNode.new("")
     @root.parent = nil
     current_node = @root
     @raw_config.each_line do |line|
       # For every line of config we match against every token
       TOKENS.each do |token|
         if line =~ token[:matcher]
           # When we find a match...
           if token[:klass].new("").is_a? FieldPropertyNode
             # In Property field we have to set it to a FieldDeclarationNode (an artificial node grouping those fields)
             if !current_node.is_a? FieldDeclarationNode
               # A new FieldDeclaration has to ve created
               node = FieldDeclarationNode.new("")
               node.properties[:field_name] = $1
               current_node.add_child node
               current_node = node
             elsif current_node.properties[:field_name] != $1
               if (aux = @root.children_of_class(FieldDeclarationNode).find { |i| i.properties[:field_name] == $1 } )
                 current_node =  aux
               else
                 # We use the one declared before (note that different metrics could not be interlaced)
                 node = FieldDeclarationNode.new("")
                 node.properties[:field_name] = $1
                 current_node.parent.add_child node
                 current_node = node
               end
             end
             current_node.add_child token[:klass].send("new",line)
           else
             @root.add_child token[:klass].send("new",line)
           end
           break
        end
      end
    end
  end
end
