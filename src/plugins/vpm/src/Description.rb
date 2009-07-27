#!/usr/bin/ruby
#

###
#
# File: Description.rb
#
######


###
#
# (c) 2009, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       Description.rb
# @author     Bjoern Rennhak
# @since      Fri Jul  3 05:23:16 JST 2009
# @version    0.0.1
# @copyright  See COPYRIGHT file for details.
#
#######



###
#
# @class   Description.rb
# @author  Bjoern Rennhak
# @brief   Description is a very simple lookup table for the VPM markers and their meaning. It is
#          used by segment in the standard configuration.
#
#######
class Description
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
  end


  attr_reader :markers
end


# Direct invocation, for manual testing beside rspec
if __FILE__ == $0
  d = Description.new
  # p d.markers.length

end


# vim=ts:2

