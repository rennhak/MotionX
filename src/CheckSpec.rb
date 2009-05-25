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
  def initialize path, filename, libraries = %[yaml]

    @file       = "#{path}/#{filename}"
    @libraries  = libraries

    # Some simple sanity testing
    self.exist?
    self.readable?

    # Load all libraries as defined in 'libraries'
    @libraries.each do |lib|
      loadLibrary! lib
    end

  end


  #### === Helper Methods

  # = Checks if the XYAML Spec file exists.
  def exist? file = @file
    raise ArgumentError, "XYAML Specification file not found." unless File.exist?( file )
  end

  # = Checks wheather the XYAML Spec file is readable or not.
  def readable? file = @file
    raise ArgumentError, "XYAML Specification file not readable." unless File.readable?( file )
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

  # = Checks wheather the XYAML Specification file contains only valid YAML.
  def valid? file = @file
      File.open( @file ) { |f| YAML::load( f ) }
  end


  #### === Meta Magic

  attr_reader :file
  
end


# = Direct invocation, not loaded as a library
if __FILE__ == $0
  # c = CheckSpec.new( "../specification", "XYAMLSpecification.yaml" ).loadLibraries!
end


