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


# You need to match this version number to the XYAML Spec file version number, otherwise tests WILL fail.
@@version = "0.0.1"

# = CheckSpec expects a certain set of sections in the XYAML Spec file.
# This is necessary to give plugin developers a stable development environment they can use to
# work on. If you change the XYAML spec file at section level you NEED to change it here to otherwise the
# tests *WILL* break. With this we want to ensure test spec file and spec file match in case you
# plan to do something fancy.
@@sections = %w[
                  version
                  
                  metadata
                  
                  metadata.motion
                  metadata.motion.name
                  metadata.motion.category
                  metadata.motion.by
                  metadata.motion.gender
                  metadata.motion.capturedTime
                  metadata.motion.capturedBy
                  metadata.motion.clothes
                  metadata.motion.utils
                  metadata.motion.contact
                  
                  metadata.capture
                  metadata.capture.device
                  metadata.capture.way
                  metadata.capture.sensors
                  metadata.capture.area
                  metadata.capture.placement
                  
                  metadata.sound
                  metadata.sound.format
                  metadata.sound.format.file
                  metadata.sound.format.file.before
                  metadata.sound.format.file.now
                  metadata.sound.format.data
                  metadata.sound.format.data.segments
                  metadata.sound.format.data.category
                  metadata.sound.format.data.frames
                  metadata.sound.format.data.frames.perSecond
                  metadata.sound.format.data.frames.time
                  metadata.sound.format.data.frames.amount
                  
                  metadata.maintenance
                  metadata.maintenance.contact
                  metadata.maintenance.convertedtime
                  metadata.maintenance.motionCaptureConverterVersion
                  
                  motion
                  motion.mySensor
                  motion.mySensor.myCategory
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

  it "should have matching version between RSpec Tests and XYAML Spec" do
    checkSpec = CheckSpec.new( "../specification", "XYAMLSpecification.yaml" )
    raise ArgumentError, "This test file (CheckSpec_spec.rb) is for XYAML Spec file (Version: #{@@version}) but the supplied XYAML Spec file is different (Version: #{checkSpec.version?})." unless ( @@version == checkSpec.version? )
  end

  # To ensure that driver developers have a certain fixed interface we will check the XYAML spec file for certain sections.
  @@sections.each do |section|
    it "should find a ,#{section.to_s}' section in the Specification XYAML specification file" do
      checkSpec = CheckSpec.new( "../specification", "XYAMLSpecification.yaml" ).section?( section.to_s )
    end
  end



  #  commit 3843aa3b38b2d7e6802485e81f3110883a262173
  #  Author: br <br@omega.omega>
  #  Date:   Wed Jun 24 19:49:42 2009 +0900
  #  
  #      - Abandoning my idea of writing a test function which parses the spec file and then checks if YAML
  #      generated correctly. First, this is useless (even though its a funny hack). Second, this makes no
  #      sense because we have to hardcode against the templates anyway.
  #      XYAMLSpecification.yaml->ostructs->template_uses_ostruct. This chain is static and if you make
  #      significatant changes in the Spec then the templates have to reflect that. Metamagic makes no sense
  #      here, for now.
  #
  #
  #  it "should have matching sections between test spec file and spec file" do
  #     checkSpec = CheckSpec.new( "../specification", "XYAMLSpecification.yaml" )
  #     unless( @@sections == checkSpec.getXYAMLSections )
  #       d1 = @@sections - checkSpec.getXYAMLSections
  #       d2 = checkSpec.getXYAMLSections - @@sections
  #       raise ArgumentError, "This test file (CheckSpec_spec.rb) has different (missing?) @@sections than contained in the XYAML Spec file
  #                             \n(\n\t(\n\t\t#{d1.join(",\n\t\t")}),\n\t(#{d2.join(",\n\t\t")}\n\t)\n\n)"
  #     end
  #  end


end # describe


