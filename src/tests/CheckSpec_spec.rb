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


# CheckSpec expects a certain set of sections in the XYAML Spec file.
# This is necessary to give plugin developers a stable development environment they can use to
# work on. If you change the XYAML spec file at section level you NEED to change it here to otherwise the
# tests *WILL* break.
@@sections = %w[
                  version
                  metadata
                  motion
               ]



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

  # To ensure that driver developers have a certain fixed interface we will check the XYAML spec file for certain sections.
  @@sections.each do |section|
    it "should find a ,#{section.to_s}' section in the Specification XYAML specification file" do
      checkSpec = CheckSpec.new( "../specification", "XYAMLSpecification.yaml" ).section?( section.to_s )
    end
  end


  #it "should find a ,motion' section in the Specification XYAML specification file" do
  #  checkSpec = CheckSpec.new( "../specification", "XYAMLSpecification.yaml" ).section?( "motion" )
  #end


  #it "should have valid top level categories in the XYAML Spec. file" do
  #  checkSpec = CheckSpec.new( "../specification", "XYAMLSpecification.yaml" ).
  #end


end # describe


