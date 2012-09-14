require 'uri'

class ASTNode

  attr_accessor :properties, :children, :parent , :root_node, :graph_properties

  def default_colors
    %w(#00CC00 #0066B3 #FF8000 #FFCC00 #330099 #990099 #CCFF00 #FF0000 #808080
       #008F00 #00487D #B35A00 #B38F00         #6B006B #8FB300 #B30000 #BEBEBE
       #80FF80 #80C9FF #FFC080 #FFE680 #AA80FF #EE00CC #FF8080
       #666600 #FFBFFF #00FFCC #CC6699 #999900)
  end

  def initialize(raw_data)
    @root_node = nil
    @raw_data = raw_data
    @children = []
    @properties = {'graph_period' => "seconds","category" => "other"}
    @graph_properties = {}    
    @graph_properties[:colorList] = default_colors
    @parent = nil
  end

  def config=(config)
    self.properties.merge!(config)
  end

  def root?
    @root_node == nil
  end

  def children_of_class(klass)
    children.select { |i| i.is_a? klass }
  end
  
  # Add a child to the node
  def add_child(child)
    if self.root?
      child.root_node = self
    else
      child.root_node = self.root_node
    end

    child.parent = self
    children << child
  end

  def compile
    # The compilation is done twice cause there are certain cases where is necessary, a better implementation would control whether this is needed
    # or not, but given the small impact I just do it twice
    children.map{|i| i.compile} if children
    children.map{|i| i.compile} if children
  end
  
  # Returns the FieldDeclaration Nodes
  def targets
    children_of_class(FieldDeclarationNode)
  end

  def process_variables(properties)
    [:vtitle,:title].each do |key|
      aux = properties[key]
      properties[key].scan(/\$\{(.*)\}/).each do 
        if self.properties.has_key? $1
          aux.gsub!(/\$\{#{$1}\}/,self.properties[$1])
        end
      end if properties[key]
      properties[key] = aux

    end
  end
  
  # Returns the global properties as url values
  def properties_to_url
    
    # Color List initialization
    aux_graph_properties = self.graph_properties.clone
    process_variables(aux_graph_properties)
    aux_graph_properties[:colorList] = aux_graph_properties[:colorList].join(",") if aux_graph_properties[:colorList]

    # Change of the base stuff
    if  self.properties[:base]
      aux_graph_properties[:yMax] = aux_graph_properties[:yMax].to_f / self.properties[:base] 
      aux_graph_properties[:yMin] = aux_graph_properties[:yMin].to_f / self.properties[:base]
      aux_graph_properties.delete :yMax 
      aux_graph_properties.delete :yMin
    end

    aux = aux_graph_properties.map{|i,j| "#{i}=#{URI.escape(j.to_s.gsub('%','percent'))}"}.join("&")
    return aux
  end

  # This returns the url field of the graph after compiling it
  def url
    self.compile
    url = "#{properties[:endpoint]}/render/?width=586&height=308&#{properties_to_url}&target=" + URI.escape(targets.map{|i| i.compile}.compact.join("&target="))
  end

  def to_gdash
    output = ""
    self.compile
    self.graph_properties.each do |k,v| 
      output += k.to_s + "\t\t" + '"' + v.to_s + '"' + "\n" unless k == :colorList || k == :yMin || k== :yMax
    end
    count = 0
    targets.each do |tg|
      metric_alias = tg.properties.delete(:alias)
      tg.children.delete_if { |i| i.class == LabelFieldPropertyNode}
      output += "field :#{tg.metric.split(".").last.to_sym},:alias => '#{metric_alias}', :data => \"#{tg.compile}\"\n"
      count += 1
    end
    return output
  end

end


class GlobalDeclarationNode < ASTNode
  def initialize(line)
    super
    line =~ /^([\w_]*)\ (.*)/
    @value = $2
  end
end

def string_to_ansi(string)
  string.unpack("U*").map{|c|c.chr}.join
end

class GraphTitleGlobalDeclarationNode < GlobalDeclarationNode
  def compile
    root_node.graph_properties[:title] = @value
  end
end

class GraphVLabelGlobalDeclarationNode < GlobalDeclarationNode
  def compile
    root_node.graph_properties[:vtitle] = @value
  end
end

class CreateArgsGlobalDeclarationNode < GlobalDeclarationNode
end

class GraphArgsGlobalDeclarationNode < GlobalDeclarationNode
  def compile
    if @raw_data =~ /--base\ (\d+)/
      self.root_node.properties[:base] = $1.to_i
    end
    if @raw_data =~ /.*logarithmic.*/
      self.root_node.properties[:logarithmic] = true
    end
  end
end

class GraphCategoryGlobalDeclarationNode < GlobalDeclarationNode
  def compile
    root_node.properties["category"] = @value
  end
end

class GraphInfoGlobalDeclarationNode < GlobalDeclarationNode; end
class GraphOrderGlobalDeclarationNode < GlobalDeclarationNode; end
class GraphTotalGlobalDeclarationNode < GlobalDeclarationNode; end
class GraphScaleGlobalDeclarationNode < GlobalDeclarationNode; end
class GraphGlobalDeclarationNode < GlobalDeclarationNode; end
class HostNameGlobalDeclarationNode < GlobalDeclarationNode
  def compile
    if @raw_data =~ /host_name (.*)$/
      root_node.properties['hostname'] = $1
    end
  end
end
class UpdateGlobalDeclarationNode < GlobalDeclarationNode; end
class GraphPeriodGlobalDeclarationNode < GlobalDeclarationNode; 
  def compile
    if @raw_data =~ /graph_period (.*)$/
      root_node.properties['graph_period'] = $1
    end
  end
end
class GraphVTitleGlobalDeclarationNode < GlobalDeclarationNode; end
class ServiceOrderGlobalDeclarationNode < GlobalDeclarationNode; end
class GraphWidthGlobalDeclarationNode < GlobalDeclarationNode; end
class GraphHeightGlobalDeclarationNode < GlobalDeclarationNode; end
class GraphPrintFormatGlobalDeclarationNode < GlobalDeclarationNode; end


class FieldDeclarationNode < ASTNode
 
  def metric
    [
     root_node.properties['graphite_user'],
     root_node.properties['graphite_prefix'],
     root_node.properties['hostname'].split('.').first,
     root_node.properties['category'],
     root_node.properties['metric'],
     children.first.metric
    ].reject{|i| i == "" }.compact.join(".")
  end

  def compile
    aux = children.first.apply_function(metric.gsub("-","_"))
    children[1..-1].each do |i|
      aux = i.apply_function(aux)
    end if children[1..-1]
    if self.root_node.properties[:logarithmic]
      # NOT IMPLEMENTED the logarithmic means that a logarithmic scale is to be used not that a log function has to be implemented aux = "log(#{aux},10)"
    end
    if self.properties[:stacked]
      aux = "stacked(#{aux})"
    end
    if self.properties[:is_negative]
      aux = "scale(#{aux},-1)"
      self.properties[:alias] = "" # legend is discarded in this case (munin does so)
    end
    if self.properties[:alias]
      aux =  "alias(#{aux},'#{self.properties[:alias]}')"
    end
    if self.properties[:hide]
      return nil
    else
      return aux
    end
  end

  def index
    return parent.children_of_class(FieldDeclarationNode).index(self)
  end

end

class FieldPropertyNode < ASTNode
  attr_accessor :metric
  
  def initialize(line)
    super   
    line =~ /([\w_]+)\.(\w+)\ (.*)$/
    @metric   = $1
    @function = $2
    @value    = $3
  end
  
  def apply_function(operand)
    return "FUNCION(#{operand})"
  end
  
end

class LabelFieldPropertyNode < FieldPropertyNode; 
  def apply_function(operand)
    parent.properties[:alias] = @value
    return operand
  end
end

class ColourFieldPropertyNode < FieldPropertyNode
  
  def apply_function(operand)
    # In this case a function can't be applied cause graphite does not allow this
    # instead we modify a given
    aux = @value  
    aux = "##{@value}"   if @value =~ /[0-9A-Fa-f]{3,6}/
    
    self.root_node.graph_properties[:colorList] ||= Array.new
    self.root_node.graph_properties[:colorList][parent.index] = aux
    return operand
  end
end

class TypeFieldPropertyNode < FieldPropertyNode
  
  def apply_function(operand)
    if @value == "DERIVE" || @value == "COUNTER"
      # The scaling is because of the minutes/(60*seconds)"
      #return "scale(nonNegativeDerivative(#{operand}),0.0166666666666667)"
      return "scaleToSeconds(nonNegativeDerivative(#{operand}),1)"
    end
    operand
  end
end

class DrawFieldPropertyNode < FieldPropertyNode
  def apply_function(operand)
    if @value == "STACK" || @value == "AREA"
      parent.properties[:stacked] = true
    end
    return operand
  end
end


class MinFieldPropertyNode < FieldPropertyNode
  def apply_function(operand)
    self.root_node.graph_properties[:yMin] ||= @value.to_i
    self.root_node.graph_properties[:yMin] = @value.to_i if  self.root_node.graph_properties[:yMin] > @value.to_i 
    return operand
  end
end

class MaxFieldPropertyNode < FieldPropertyNode
  def apply_function(operand)
    self.root_node.graph_properties[:yMax] ||= @value.to_i
    self.root_node.graph_properties[:yMax] = @value.to_i if  self.root_node.graph_properties[:yMax] < @value.to_i 
    return operand
  end
end

class InfoFieldPropertyNode < FieldPropertyNode
  def apply_function(operand)
   # puts "Info tag is currently ignored"
    return operand
  end
end

class WarningFieldPropertyNode < FieldPropertyNode
  # Ignored
  def apply_function(operand)
    operand
  end
end

class CriticalFieldPropertyNode < FieldPropertyNode
  # Ignored
  def apply_function(operand)
    operand
  end
end


class CDefFieldPropertyNode < FieldPropertyNode
  def apply_function(operand)
    if @raw_data =~ /(\w+),(\d+),\*/      
      return "scale(#{operand},#{$2})"
    elsif @raw_data =~ /(\w+),(\d+),\//      
      return "scale(#{operand},#{1.0/$2.to_i})"
    end
    "FUNCTION(#{operand})"
  end
end

class GraphFieldPropertyNode < FieldPropertyNode
  def apply_function(operand)
    operand
  end
end

class ExtInfoFieldPropertyNode < FieldPropertyNode; end
class NegativeFieldPropertyNode < FieldPropertyNode
  def apply_function(operand)
    # We have to mark the other node as negative (note that for this to work we have to compile twice
    node = self.root_node.targets.find { |i| i.properties[:field_name] == @value }
    if node
      node.properties[:is_negative] = true 
      # We also use the same color
#      config.log.info("Begin getting metrics negative (node : #{node.index} with : #{parent.index} parent Color = root_node.graph_properties[:colorList][parent.index] ")

      root_node.graph_properties[:colorList][node.index] = root_node.graph_properties[:colorList][parent.index] if root_node.graph_properties[:colorList][parent.index]
    end
    return operand
  end
end

class SkipDrawFieldPropertyNode < FieldPropertyNode; end
class SumFieldPropertyNode < FieldPropertyNode; end
class StackFieldPropertyNode < FieldPropertyNode; end
class LineValueFieldPropertyNode < FieldPropertyNode; end
class OldNameFieldPropertyNode < FieldPropertyNode; end
class ValueFieldPropertyNode < FieldPropertyNode; end
