#!/usr/bin/ruby -w
#

###
#
# File: CheckSpec.rb
#
# (c) 2009, Bjoern Rennhak, The University of Tokyo
# CheckSpec.rb reads the ../specification/XYAMLSpecification.yaml file and provides a CLI interface to
# either output the specific problem or only a binary switch if the spec is ok (TRUE, 1) or not ok
# (FALSE, 0).
#
# This tool is normally used by developers who extend the XYAMLSpecification.yaml file not by
# end-users.
#
#########


# = Standard requires will get executed in the Object creation program flow.
# See the CheckSpec.initialize function and if you want to add more see the initialize function
# head.

# = The CheckSpec class. It provides functionality to check wheather the XYAMLSpecification is ok or
# not. It is implemented in BDD style with tests/CheckSpec_spec.rb. ( spec tests/CheckSpec_spec.rb
# --format specdoc)
class CheckSpec

  # = The initialize function is the default and custom ctor which inits this class.
  # @param path Needs a string which describes the location (path) where the spec file is. (w/o trailing slash)
  # @param filename Needs a string which is the filename of the XYAML spec file. (w/o slashes)
  # @param libraries Add here the names of the require libraries you want to add. Spaces speparate the entries.
  def initialize path, filename, libraries = %w[yaml ostruct Extensions.rb]

    @file       = "#{path}/#{filename}"
    @libraries  = libraries

    # Some simple sanity testing
    self.exist?
    self.readable?

    # Load all libraries as defined in 'libraries'
    @libraries.each { |lib| loadLibrary! lib }

    # Load the XYAML Spec file and map it into a Ostruct
    @data = load!
    # @template = OpenStruct.new( data ).remap!

  end


  #### === Helper Methods

  # == Loads the XYAML Specification file
  def load! file = @file, ostruct = true
    if( ostruct )
      res = File.open( @file, "r" ) { |file| YAML.load( file ) }                 # return proc which is in this case a hash
    else
      # Ugly Ugly hack, find out how to switch dynamically and remove namespace pollution.
      class << YAML::DefaultResolver
          alias_method :node_import, :_node_import
      end

      res = File.open( @file, "r" ) { |file| YAML.load( file ) }

      class << YAML::DefaultResolver
          alias_method :_node_import, :node_import
          def node_import(node)
              o = _node_import(node)
              o.is_a?(Hash) ? OpenStruct.new(o) : o
          end
      end

    end

    res
  end

  # = Checks if the XYAML Spec file exists.
  def exist? file = @file
    raise ArgumentError, "XYAML Specification file not found." unless File.exist?( file )
  end

  # = Checks wheather the XYAML Spec file is readable or not.
  def readable? file = @file
    raise ArgumentError, "XYAML Specification file not readable." unless File.readable?( file )
  end

  # = Returns the version of the XYAML Spec file
  def version?
    @data.version
  end

  # = Loads a given Library, e.g. 'yaml'
  # @warning Requires without check. This method needs repairing.
  def loadLibrary! name
    require "#{name.to_s}"

    # FIXME: Seems to be impossible to write this?
    # Search in the ObjectSpace if we already loaded name or NAME.
    #
    # unless( ObjectSpace.each_object( Module ).include?(name) or ObjectSpace.each_object( Module ).include?(name.upcase) ) 
    #   raise ArgumentError, "Can't load the #{name.to_s} library. Please install it, e.g. via gem." unless require "#{name.to_s}"
    # end
  end

#  # = Extracts the given section from the XYAML Spec file and returns them as an Array
#  # @param name Expects a valid section and returns the subsections, e.g. name = "metadata" returns
#  # "["motion", "sound", "capture", "maintenance"]"
#  # This is a helper function for getAllXYAMLSections
#  def getXYAMLSection name
#    return nil if( eval("@data.#{name.to_s}.class").to_s == "String" )
#    value = ( eval("@data.#{name.to_s}.methods").to_a \
#        - YAML.load( "" ).methods \
#        - %w[marshal_dump method_missing table marshal_load delete_field new_ostruct_member] ).collect! { |m| m unless m =~ %r{=}i  }.compact!
#  end
#
#
#  # = Extracts the sections from the XYAML Spec file and returns them as an Array
#  # FIXME: Construct a proper recursion to capture all sections with a proper test
#  def getXYAMLSections
#    sections  = []              # our final result
#    todo      = []              # our array with items we have to lookup
#
#
#    thunk = lambda do |key, value|
#      case value
#        when Hash then sections << value ; value.each( &thunk )
#      end
#    end
#
#
#    tuple = load!( @file, false )
#    tuple.each_pair do |k,v|
#      if( v.is_a?( Hash ) )
#        #puts "Key: #{k.to_s} -> Value --> Hash"
#        v.each( &thunk )
#      else
#        #puts "Key: #{k.to_s} -> Value: #{v.to_s}"
#      end
#    end
#
#    sections.each do |s|
#      puts s
#    end
#
#    # get the initial symbols and store them for later and also push them to todo if they contain ostructs again.
#    for k,v in @data.instance_variable_get( "@table" )
#        kIsA = eval("@data.#{k}.class")                 # e.g. @data.metadata.class => OpenStruct ; @data.version.class => String and so on
#        
#        sections << k.to_s
#        if eval( "@data.#{k}.class" ).to_s == "OpenStruct"    # ??! .is_a?( OpenStruct ) ??? FIXME
#          todo << k.to_s
#        end
#    end
#
#    thunk = lambda do |key, value|
#      case value
#        when String     then value
#        when OpenStruct then sections << value ; value.each( &thunk )
#      end
#    end
#
#    p @data.instance_variable_get( "@table" ).each( &thunk )
#    p sections
#    # Iterate over all ostructs until none are left
#    #while not todo.empty?
#    #  item = todo.shift
#    #  for k, v in 
#    #end
#
#    #puts ""
#    #p "SECTIONS: ", sections
#    #puts ""
#    #p "TODO: ", todo
#
##    # get all subsections and so on - FIXME
##    top.each do |s|
##      subset = ( getXYAMLSection( s ) ).to_a.collect { |n| "#{s.to_s}.#{n.to_s}" }
##      subset.each do |ss|
##        sections << ( getXYAMLSection( ss ) ).to_a.collect { |nn| "#{ss.to_s}.#{nn.to_s}" }
##      end
##      sections << subset
##    end
##
#    #sections.flatten
#  end


  # = Checks wheather a given name is a existing section of the XYAML spec
  # @returns Boolean, true if it exists false if not.
  def section? name
    raise ArgumentError, "XYAML Specification does not contain the section ,#{name.to_s}'" if eval("@data.#{name.to_s}.nil?")
  end

  # = Checks wheather the XYAML Specification file contains only valid YAML.
  def valid? file = @file
      File.open( @file ) { |f| YAML::load( f ) }
  end


  #### === Meta Magic
  attr_reader :file, :data
end


# = Direct invocation, not loaded as a library
if __FILE__ == $0
  c = CheckSpec.new( "../specification", "XYAMLSpecification.yaml" )
  # c.getXYAMLSections
end


