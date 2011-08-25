require 'uri'

class ASTNode

  attr_accessor :properties, :children, :parent , :root_node, :graph_properties

  def initialize(raw_data)
    @root_node = nil
    @raw_data = raw_data
    @children = []
    @properties = {}
    @graph_properties = {}
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
    children.map{|i| i.compile} if children
  end
  
  # Returns the FieldDeclaration Nodes
  def targets
    children_of_class(FieldDeclarationNode)
  end
  
  # Returns the global properties as url values
  def properties_to_url

    # Color List initialization
    aux_graph_properties = self.graph_properties.clone
    aux_graph_properties[:colorList] = aux_graph_properties[:colorList].join(",") if aux_graph_properties[:colorList]

    # Change of the base stuff
    if  self.properties[:base]
      aux_graph_properties[:yMax] = aux_graph_properties[:yMax].to_f / self.properties[:base] 
      aux_graph_properties[:yMin] = aux_graph_properties[:yMin].to_f / self.properties[:base]
      aux_graph_properties.delete :yMax 
      aux_graph_properties.delete :yMin
    end

    aux = aux_graph_properties.map{|i,j| "#{i}=#{URI.escape(j.to_s)}"}.join("&")
    return aux
  end

  # This returns the url field of the graph after compiling it
  def url
    self.compile
    url = "#{properties[:endpoint]}/render/?width=586&height=308&#{properties_to_url}&target=" + URI.escape(targets.map{|i| i.compile}.compact.join("&target="))
  end

end


class GlobalDeclarationNode < ASTNode
  def initialize(line)
    super
    line =~ /^(\w*)\ (.*)/
    @value = $2
  end
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
    root_node.properties[:category] = @value
  end
end

class GraphInfoGlobalDeclarationNode < GlobalDeclarationNode; end
class GraphOrderGlobalDeclarationNode < GlobalDeclarationNode; end
class GraphTotalGlobalDeclarationNode < GlobalDeclarationNode; end
class GraphScaleGlobalDeclarationNode < GlobalDeclarationNode; end
class GraphGlobalDeclarationNode < GlobalDeclarationNode; end
class HostNameGlobalDeclarationNode < GlobalDeclarationNode; end
class UpdateGlobalDeclarationNode < GlobalDeclarationNode; end
class GraphPeriodGlobalDeclarationNode < GlobalDeclarationNode; end
class GraphVTitleGlobalDeclarationNode < GlobalDeclarationNode; end
class ServiceOrderGlobalDeclarationNode < GlobalDeclarationNode; end
class GraphWidthGlobalDeclarationNode < GlobalDeclarationNode; end
class GraphHeightGlobalDeclarationNode < GlobalDeclarationNode; end
class GraphPrintFormatGlobalDeclarationNode < GlobalDeclarationNode; end


class FieldDeclarationNode < ASTNode
 
  def metric
    "#{root_node.properties[:graphite][:metric_prefix]}.#{root_node.properties[:hostname]}.#{root_node.properties[:category]}.#{root_node.properties[:metric]}.#{children.first.metric}"
  end

  def compile
    aux = children.first.apply_function(metric)
    children[1..-1].each do |i|
      aux = i.apply_function(aux)
    end if children[1..-1]
    if self.root_node.properties[:logarithmic]
      aux = "log(#{aux},10)"
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
    line =~ /(\w+)\.(\w+)\ (.*)$/
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
      return "nonNegativeDerivative(#{operand})"
    end
    operand
  end
end

class DrawFieldPropertyNode < FieldPropertyNode
  def apply_function(operand)
    if @value == "STACK" || @value == "AREA"
      return "stacked(#{operand})"
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
    return "scale(#{operand},-1)"
  end
end

class SkipDrawFieldPropertyNode < FieldPropertyNode; end
class SumFieldPropertyNode < FieldPropertyNode; end
class StackFieldPropertyNode < FieldPropertyNode; end
class LineValueFieldPropertyNode < FieldPropertyNode; end
class OldNameFieldPropertyNode < FieldPropertyNode; end
class ValueFieldPropertyNode < FieldPropertyNode; end
