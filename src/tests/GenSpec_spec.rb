###
#
# File: GenSpec_spec.rb
#
# (c) 2009, Bjoern Rennhak, The University of Tokyo
#
# This file is a Ruby RSpec testing file for the GenSpec generator tool of the XYAML Specification
# file.
#
######


require 'GenSpec.rb'


# Lets describe what the object can and can't do.
describe GenSpec do

  it "should be able to require the YAML library" do
    genSpec = GenSpec.new( "../specification", "XYAMLSpecification.yaml" ).loadLibrary!( "yaml" )
  end

  it "should be able to require the OSTUCT library" do
    genSpec = GenSpec.new( "../specification", "XYAMLSpecification.yaml" ).loadLibrary!( "ostruct" )
  end

  it "should be able to require the ERB library" do
    genSpec = GenSpec.new( "../specification", "XYAMLSpecification.yaml" ).loadLibrary!( "erb" )
  end

  it "should be able to require the Extensions.rb hacks" do
    genSpec = GenSpec.new( "../specification", "XYAMLSpecification.yaml" ).loadLibrary!( "Extensions.rb" )
  end

  # Checks if we have our meta-lang-gen methods
  %w[rb c cpp].each do |extension|
    it "should have a generate#{extension.to_s.upcase} method" do
      genSpec = GenSpec.new( "../specification", "XYAMLSpecification.yaml" )
      raise ArgumentError, "Don't have a ,generate#{extension.to_s.upcase}' method" unless genSpec.methods.include?( "generate#{extension.to_s.upcase}" )
    end
  end

  it "should find a Ruby template -?-> template/Ruby.erb" do
    raise ArgumentError, "Couldn't find a Ruby.erb template in template/.. " unless File.exist?( "templates/Ruby.erb" )
  end


  # FIXME: Missing test for "GenSpec.output"


end # describe


