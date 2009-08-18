#!/usr/bin/ruby
#

###
#
# File: Body.rb
#
######


###
#
# (c) 2009, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       Body.rb
# @author     Bjoern Rennhak
# @since      Fri Jul  3 05:23:16 JST 2009
# @version    0.0.1
# @copyright  See COPYRIGHT file for details.
#
#######


# require 'ostruct'
require 'Extensions.rb'


###
#
# @class   Body.rb
# @author  Bjoern Rennhak
# @brief   Body is a very simple lookup table for the VPM markers and their meaning. It is
#          used by segment in the standard configuration.
#
#######
class Body
  def initialize
    
    # This is taken from the PhD Thesis of S. Kudoh, p. 117
    @markers = {
      "LFHD" => "The left front of the head",
      "LBHD" => "The left back of the head",
      "RFHD" => "The right front of the head",
      "RBHD" => "The right back of the head",
      "CLAV" => "The middle of the two clavicle",
      "STRN" => "The pit of the stomach",
      "T10"  => "The spine opposite to STRN",
      "C7"   => "The back of the neck",
      "LSHO" => "The left shoulder",
      "LELB" => "The left elbow",
      "LWRA" => "The left wrist (the radius side)",
      "LWRB" => "The left wrist (the ulna side)",
      "LFIN" => "The center of the back of the left hand",
      "RSHO" => "The right shoulder",
      "RELB" => "The right elbow",
      "RWRA" => "The right wrist (the radius side)",
      "RWRB" => "The right wrist (the ulna side)",
      "RFIN" => "The center of the back of the right hand",
      "LFWT" => "The left front of the waist",
      "LBWT" => "The left back of the waist",
      "LTHI" => "The left thigh",
      "LKNE" => "The left knee",
      "LANK" => "The left ankle",
      "LHEE" => "The left heel",
      "LTOE" => "The left toe",
      "LMT5" => "The left little toe",
      "RFWT" => "The right front of the waist",
      "RBWT" => "The right back of the waist",
      "RKNE" => "The right knee",
      "RANK" => "The right ankle",
      "RHEE" => "The right heel",
      "RTOE" => "The right toe",
      "RMT5" => "The right little toe",
    }


    ###
    # Hierachical model to address certain segments
    # e.g. @body.legs.left.thigh = ...
    ########
    @body             = OpenStruct.new

    %w[head chest loins arms legs].each { |part| eval( "@body.#{part.to_s} = OpenStruct.new" ) }                                # Create "big" containers

    %w[left right].each do |orientation|
      %w[arms legs].each        { |part| eval( "@body.#{part.to_s}.#{orientation.to_s} = OpenStruct.new" ) }                    # Create left/right subparts for arms/legs
      %w[upper fore hand].each  { |part| eval( "@body.arms.#{orientation.to_s}.#{part.to_s} = OpenStruct.new" ) }               # Create upper arm / fore arm / hand
      %w[thigh shank foot].each { |part| eval( "@body.legs.#{orientation.to_s}.#{part.to_s} = OpenStruct.new" ) }               # Create thigh, shank, foot
    end

    ###
    # Mass in percent (See S. Kudoh PhD Thesis p. 45)
    ########
    @mass = {
      "head"      => 7.0,
      "chest"     => 25.8,
      "loins"     => 17.2,
      "upper arm" => 3.6,
      "fore arm"  => 2.2,
      "hand"      => 0.7,
      "thigh"     => 11.4,
      "shank"     => 5.3,
      "foot"      => 1.8
    }

    # Create ".mass" and ".segments" for all components
    %w[mass segments].each do |var|
      %w[head chest loins arms legs].each { |part| eval( "@body.#{part.to_s}.#{var.to_s} = OpenStruct.new" ) }                                # Create "big" containers

      %w[left right].each do |orientation|
        %w[arms legs].each        { |part| eval( "@body.#{part.to_s}.#{orientation.to_s}.#{var.to_s} = OpenStruct.new" ) }                    # Create left/right subparts for arms/legs
        %w[upper fore hand].each  { |part| eval( "@body.arms.#{orientation.to_s}.#{part.to_s}.#{var.to_s} = OpenStruct.new" ) }               # Create upper arm / fore arm / hand
        %w[thigh shank foot].each { |part| eval( "@body.legs.#{orientation.to_s}.#{part.to_s}.#{var.to_s} = OpenStruct.new" ) }               # Create thigh, shank, foot
      end

    end

    # Why does this not work? - FIXME
    # @body.dup._to_hash.flatten_keys.getKeysOfNestedHash.each do |keys|
    #  puts "@body.#{keys.to_s}.mass = OpenStruct.new"
    #  eval("puts @body.#{keys.to_s}.class")
    #  eval( "@body.#{keys.to_s}.mass = OpenStruct.new" )
    # end

    # Set the mass to all components
    @body.head.mass             = @mass["head"]
    @body.chest.mass            = @mass["chest"]
    @body.loins.mass            = @mass["loins"]

    @body.arms.left.mass        = @mass["upper arm"] + @mass["fore arm"] + @mass["hand"]
    @body.arms.right.mass       = @body.arms.left.mass
    @body.arms.mass             = @body.arms.left.mass + @body.arms.right.mass
    @body.arms.left.upper.mass  = @mass["upper arm"]
    @body.arms.right.upper.mass = @mass["upper arm"]
    @body.arms.left.fore.mass   = @mass["fore arm"]
    @body.arms.right.fore.mass  = @mass["fore arm"]
    @body.arms.left.hand.mass   = @mass["hand"]
    @body.arms.right.hand.mass  = @mass["hand"]

    @body.legs.left.mass        = @mass["thigh"] + @mass["shank"] + @mass["foot"]
    @body.legs.right.mass       = @body.legs.left.mass
    @body.legs.mass             = @body.legs.left.mass + @body.legs.right.mass
    @body.legs.left.thigh.mass  = @mass["thigh"]
    @body.legs.left.shank.mass  = @mass["shank"]
    @body.legs.left.foot.mass   = @mass["foot"]
    @body.legs.right.thigh.mass = @mass["thigh"]
    @body.legs.right.shank.mass = @mass["shank"]
    @body.legs.right.foot.mass  = @mass["foot"]

    @body.mass                  = @body.head.mass + @body.chest.mass + @body.loins.mass + @body.arms.mass + @body.legs.mass

    @body.segments              = @markers

  end # of initialize


  attr_reader :markers, :body, :mass
end # of class Body


# Direct invocation, for manual testing beside rspec
if __FILE__ == $0
  d = Body.new

  # p d.body._to_hash.flatten_keys.getKeysOfNestedHash
end


# vim=ts:2

