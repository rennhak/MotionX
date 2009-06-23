#!/usr/bin/ruby -w
#

###
#
# File: GenSpec.rb
#
# (c) 2009, Bjoern Rennhak, The University of Tokyo
# GenSpec.rb reads the ../specification/XYAMLSpecification.yaml file and provides a CLI interface to
# output a XYAML.{c|rb|cpp}.
#
# This tool is normally used by developers who extend the XYAMLSpecification.yaml file not by
# end-users.
#
#########


# = Standard requires will get executed in the Object creation program flow.
# See the GenSpec.initialize function and if you want to add more see the initialize function
# head.

# = The GenSpec class. It provides functionality to generate code from the XYAMLSpecification.
# test/CheckSpec_spec.rb *MUST* execute successfully in order to expect good results in this step.
# It is implemented in BDD style with tests/GenSpec_spec.rb. ( spec tests/GenSpec_spec.rb
# --format specdoc)
class GenSpec

  # = The initialize function is the default and custom ctor which inits this class.
  # @param path Needs a string which describes the location (path) where the spec file is. (w/o trailing slash)
  # @param filename Needs a string which is the filename of the XYAML spec file. (w/o slashes)
  # @param libraries Add here the names of the require libraries you want to add. Spaces speparate the entries.
  def initialize path, filename, targetPath = ".", targetFilenameWithExtension = "XYAML.rb", libraries = %w[yaml ostruct Extensions.rb]

    @file       = "#{path}/#{filename}"
    @libraries  = libraries

    # Load all libraries as defined in 'libraries'
    @libraries.each { |lib| loadLibrary! lib }

    # Load the XYAML Spec file and map it into a Ostruct
    @data = load!
    # @template = OpenStruct.new( data ).remap!

    # Sane default in case somebody calls us without target arguments
    @targetPath, @targetFilenameWithExtension = targetPath, targetFilenameWithExtension
  end


  # = The output function calls the specfic helper function which will actually generate $LANG
  # specific code. This depends on the given extension of the file.
  # @param path Needs a sane path without trailing slash (string)
  # @param file Needs a sane filename **WITH** proper extension. E.g. "XYAML.c" or "XYAML.cpp" or "XYAML.rb" etc. Corresponding .h's are created along the way.
  def output path, file
    #begin
      extension = file.to_s.split(".").pop
      call = "generate#{extension.to_s.upcase}( '#{path}', '#{File.basename( file, '.'+extension.to_s ) }' )"
      eval( call.to_s )
    #rescue
    #  raise ArgumentError, "The provided filename contains an invalid extension which is either spelled wrong or not supported."
    #end
  end

  # = The generateRB function (d'oh) of course pumps out a Ruby Class file to a provided filename
  # @param name Needs a string without the desired extension, e.g. "XYAML" will output "XYAML.rb"
  def generateRB path, name
    target    = "#{path}/#{name}"
    rbFile    = target + ".rb"

    raise ArgumentError, "Not implemented yet error."
    # FIXME
  end


  # = The generateC function (d'oh) of course pumps out a C file (.c) to a provided filename (and also a .h)
  # @param name Needs a string without the desired extension, e.g. "XYAML" will output "XYAML.c" and "XYAML.h"
  def generateC path, name
    target    = "#{path}/#{name}"
    cFile     = target + ".c"
    hFile     = target + ".h"

    raise ArgumentError, "Not implemented yet error."
    # FIXME
  end


  # = The generateCPP function (d'oh) of course pumps out a CPP file (.cpp) to a provided filename (and also a .hpp)
  # @param name Needs a string without the desired extension, e.g. "XYAML" will output "XYAML.cpp" and "XYAML.hpp"
  def generateCPP path, name
    target    = "#{path}/#{name}"
    cFile     = target + ".cpp"
    hFile     = target + ".hpp"

    raise ArgumentError, "Not implemented yet error."
    # FIXME
  end


  #### === Helper Methods

  # == Loads the XYAML Specification file
  def load! file = @file
    File.open( @file, "r" ) { |file| YAML.load( file ) }                 # return proc which is in this case a hash
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


  #### === Meta Magic
  attr_reader :file, :data
end


# = Direct invocation, not loaded as a library
if __FILE__ == $0
  c = GenSpec.new( "../specification", "XYAMLSpecification.yaml" )
  c.output( ".", "XYAML.rb" ) # outputs ruby - extension magic
end


