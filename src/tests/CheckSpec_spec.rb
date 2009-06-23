###
#
# File: CheckSpec_spec.rb
#
# (c) 2009, Bjoern Rennhak, The University of Tokyo
#
# This file is a Ruby RSpec testing file for the CheckSpec test tool of the XYAML Specification
# file.
#
######


require 'CheckSpec.rb'

# Lets describe what the object can and can't do.
describe CheckSpec do


  it "should find the XYAML specification file" do 
    checkSpec = CheckSpec.new( "../specification", "XYAMLSpecification.yaml" ).exist?
  end

  it "should be able to read the XYAML specification file" do
    checkSpec = CheckSpec.new( "../specification", "XYAMLSpecification.yaml" ).readable?
  end

  it "should be able to require the YAML library" do
    checkSpec = CheckSpec.new( "../specification", "XYAMLSpecification.yaml" ).loadLibrary!( "yaml" )
  end

  it "should be able to require the OSTUCT library" do
    checkSpec = CheckSpec.new( "../specification", "XYAMLSpecification.yaml" ).loadLibrary!( "ostruct" )
  end

  it "should be able to require the Extensions.rb hacks" do
    checkSpec = CheckSpec.new( "../specification", "XYAMLSpecification.yaml" ).loadLibrary!( "Extensions.rb" )
  end

  it "should validate XYAML Specification as YAML standard" do
    checkSpec = CheckSpec.new( "../specification", "XYAMLSpecification.yaml" ).valid?
  end

  it "should find a ,metadata' section in the Specification XYAML specification file" do
    checkSpec = CheckSpec.new( "../specification", "XYAMLSpecification.yaml" ).section?( "metadata" )
  end

  it "should find a ,motion' section in the Specification XYAML specification file" do
    checkSpec = CheckSpec.new( "../specification", "XYAMLSpecification.yaml" ).section?( "motion" )
  end


  #it "should have valid top level categories in the XYAML Spec. file" do
  #  checkSpec = CheckSpec.new( "../specification", "XYAMLSpecification.yaml" ).
  #end


end # describe


