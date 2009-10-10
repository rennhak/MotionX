#!/usr/bin/ruby
#

###
#
# File: Simple.rb
#
######


###
#
# (c) 2009, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       Simple.rb
# @info       A very basic example of how to use the VPM ADT
# @author     Bjoern Rennhak
# @since      Fri Jul  3 05:23:16 JST 2009
# @version    0.0.1
# @copyright  See COPYRIGHT file for details.
#
#######


require 'ADT.rb'



vpmFile = "../../../../../DanceData/Aizu_Female.vpm"

@vpm    = ADT.new( vpmFile )                                    # load the vpm file and construct convenience methods for it
@body   = @vpm.body

# What kind of segments can we access?
@body.segments.each_pair do |abbrev, description|
  printf( "%-6s | %s\n", abbrev, description )
end

# How long is the single frame time for e.g. RSHO (Right shoulder)
puts "\nSingle Frame time: " + @vpm.rsho.frameTime 

# How many frames to we have for e.g. RSHO?
puts "\nTotal Frames: " + @vpm.rsho.frames
 
# Give me all frames for e.g. RSHO and LSHO together in one array, and print only the first touple
shoulder = ( @vpm.rsho.getCoordinates! ).zip( @vpm.lsho.getCoordinates! )
puts "Shoulder [ right[x,y,z], left[x,y,z] ] : " + shoulder.first.join(", ")

# Segments support math, e.g. lets create a new segment between the right wrist and elbow
forearm = ( @vpm.rwra + @vpm.relb ) / 2
@vpm.setNewSegment!( "forearm", "Forearm of the right arm", forearm )     # we can dynamically add this to our baseclass - if we want

p "RWRA First Element: " + @vpm.rwra.getCoordinates!.first.join(", ")
p "RELB First Element: " + @vpm.relb.getCoordinates!.first.join(", ")
p "Forearm First Element: " + @vpm.forearm.getCoordinates!.first.join(", ")


# If you lack features either add them yourself and send me feedback or drop me a quick note and if
# time permits I'll implement it (if it makes sense).
#
# - Bjoern


