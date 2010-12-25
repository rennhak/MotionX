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

    # This is taken from the PhD Thesis of S. Kudoh, p. 117 in Comma first style
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
      "PT24" => "The center of the head between LFHD, LBHD, RFHD and RBHD",
      "PT25" => "The center of the shoulder blades between LSHO and RSHO",
      "PT26" => "The center of the left wrist between LWRA and LWRB",
      "PT27" => "The center of the right wrist between RWRA and RWRB",
      "PT28" => "The center of the left waist between LFWT and LBWT",
      "PT29" => "The center of the right waist between RFWT and RBWT",
      "PT30" => "The end of the spine directly above PT25 between LFWT, LBWT, RFWT and RBWT",
      "PT31" => "The solar plexus of the torso between PT25 and PT30"
    }

    @center           = :pt30

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
      "upper_arm" => 3.6,
      "fore_arm"  => 2.2,
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

      end # of %w[left right].each do |orientation|

    end # of %w[mass segments].each do |var|


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

    @body.arms.left.mass        = @mass["upper_arm"] + @mass["fore_arm"] + @mass["hand"]
    @body.arms.right.mass       = @body.arms.left.mass
    @body.arms.mass             = @body.arms.left.mass + @body.arms.right.mass
    @body.arms.left.upper.mass  = @mass["upper_arm"]
    @body.arms.right.upper.mass = @mass["upper_arm"]
    @body.arms.left.fore.mass   = @mass["fore_arm"]
    @body.arms.right.fore.mass  = @mass["fore_arm"]
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


    # Body components mapping to segments
    @body.arms.left.upper.segments        = [ :lelb, :lsho ]
    @body.arms.right.upper.segments       = [ :relb, :rsho ]

    @body.arms.left.fore.segments         = [ :pt26, :lelb ]
    @body.arms.right.fore.segments        = [ :pt27, :relb ]

    @body.arms.left.hand.segments         = [ :lfin, :pt26 ]
    @body.arms.right.hand.segments        = [ :rfin, :pt27 ]

    @body.legs.left.thigh.segments        = [ :lkne, :pt28 ]
    @body.legs.right.thigh.segments       = [ :rkne, :pt29 ]

    @body.legs.left.shank.segments        = [ :lank, :lkne ]
    @body.legs.right.shank.segments       = [ :rank, :rkne ]

    @body.legs.left.foot.segments         = [ :ltoe, :lank ]
    @body.legs.right.foot.segments        = [ :rtoe, :rank ]

    @group  = {
      :upper_arms     => [ @body.arms.right.upper.segments,  @body.arms.left.upper.segments     ],
      :fore_arms      => [ @body.arms.right.fore.segments,   @body.arms.left.fore.segments      ],
      :hands          => [ @body.arms.right.hand.segments,   @body.arms.left.hand.segments      ],
      :thighs         => [ @body.legs.right.thigh.segments,  @body.legs.left.thigh.segments     ],
      :shanks         => [ @body.legs.right.shank.segments,  @body.legs.left.shank.segments     ],
      :feet           => [ @body.legs.right.foot.segments,   @body.legs.left.foot.segments      ]
    }

  end # of initialize

  # = The function get_mass will take a components such as found in @mass but allow for plurals and other cases and return a proper mass value.
  #   Basically this is just an intelligent interface to the @mass hash
  # @param component Name of the desired component such as fore_arm -> singular or fore_arms -> plural etc
  # @returns Float, representing the mass of the desired body component
  def get_mass component # {{{
    fixed                 = %w[head chest loins]
    components_singular   = %w[upper_arm fore_arm hand thigh shank foot]
    components_plural     = %w[upper_arms fore_arms hands thighs shanks feet]

    # We have a fixed case
    if( fixed.include?( component ) )
      return @mass[ component ]
    end

    # we have a singular case
    if( components_singular.include?( component ) )
      return @mass[ component ]
    end 

    # we have a plural case
    if( components_plural.include?( component ) )
      if( component == "feet" )
        return @mass[ "foot" ] * 2
      else
        # we have just a "s" to deal with -> e.g. fore_arm -> fore_arms
        return @mass[ component.chop ] * 2
      end
    end

    raise ArgumentError, "There is something wrong with the argument (,,#{component.to_s}'') in MotionX->Body.rb::get_mass"
  end # of def get_mass # }}}

  attr_reader :markers, :body, :mass, :center, :group
end # of class Body


# Direct invocation, for manual testing beside rspec
if __FILE__ == $0
  # b = Body.new

end


# vim=ts:2

