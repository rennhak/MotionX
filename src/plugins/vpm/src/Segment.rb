#!/usr/bin/ruby
#

###
#
# File: Segment.rb
#
######


###
#
# (c) 2009, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       Segment.rb
# @author     Bjoern Rennhak
# @since      Fri Jul  3 05:23:16 JST 2009
# @version    0.0.1
# @copyright  See COPYRIGHT file for details.
#
#######


###
#
# @class   Segment
# @author  Bjoern Rennhak
# @brief   The Segment class is a helper class for the ADT class and it is a internal Abstract Data
#          Type class holding the information of the VPM file for read and writes.
#
# FIXME:   Internal use of Hash twists the keys around?? If yes, switch to array
#######
class Segment

  # = Initialize is the constructor function for this Segement class
  # @param name         Name holds the short hand or acronym of the segment, e.g. RFWT etc.
  # @param description  Desciption holds a explanation where this actually sits on the body.
  def initialize name, description
    @name, @description = name, description
    @markers            = Hash.new                       # we store our marker/unit hash here
  end

  # = setMapping! takes a segment hash and maps it internally
  # @param hash Hash is a key/value vector which was created from these two lines:
  #             XTRAN   YTRAN   ZTRAN   XROT    YROT    ZROT    XSCALE  YSCALE  ZSCALE
  #             INCHES  INCHES  INCHES  DEGREES DEGREES DEGREES PERCENT PERCENT PERCENT
  #             The keys are the marker names and the values are the units.a
  #             Each value has NO newline or other special characters and is converted automatically
  #             to lower case.
  def setMapping! hash
    hash.each_pair do |marker, unit|
      # take all markers and make sure they are downcased
      @markers[ marker.to_s.downcase ] = unit.to_s.downcase

      # generate a variable for each marker with a empty array
      self.instance_variable_set( "@#{marker.to_s.downcase}", Array.new )   # e.g. XTRAN/INCHES becomes @xtran => Array.new

      # learn getter and setter
      # TODO: doesn't ruby have a better way for this?
      learn( "#{marker.to_s.downcase} val = nil", "( val.nil? ) ? ( return @#{marker.to_s.downcase} ) : ( @#{marker.to_s.downcase} << val )"  )
    end
  end

  
  # = GetHeader returns the content of a segment header
  # FIXME: Hardcoding
  def getHeader
    delimiter = "\t"
    puts "Segment:#{delimiter}#{@name}"
    puts "Frames:#{delimiter*2}#{@frames}"
    puts "Frame Time:#{delimiter}#{@frameTime}"
    puts "XTRAN\tYTRAN\tZTRAN\tXROT\tYROT\tZROT\tXSCALE\tYSCALE\tZSCALE"
    puts "INCHES\tINCHES\tINCHES\tDEGREES\tDEGREES\tDEGREES\tPERCENT\tPERCENT\tPERCENT"
  end


  # = GetData returns the content of a frame at position index
  # @param index Index represenents one frame
  # FIXME: Hardcoding
  def getData index
    "#{xtran[index]} #{ytran[index]} #{ztran[index]} #{xrot[index]} #{yrot[index]} #{zrot[index]} #{xscale[index]} #{yscale[index]} #{zscale[index]}"
  end

  # == Dynamical method creation at run-time
  def learn method, code
      eval <<-EOS
          class << self
              def #{method}; #{code}; end
          end
      EOS
  end


  # = unit? Returns the unit this marker has in lowercase letters
  # @param markerName This variable needs a string representation of the marker you wish to know
  def unit? markerName
    raise ArgumentError, "The class 'Segment' has not been properly initialized. You have to call the segemnts! function first." if @markers.empty?
    @markers[ markerName.to_s.downcase ]
  end

  # = to_s is a pritable representation of this Segment
  # @note The formatting is probably by tabs, but we will only know this for sure if we have the spec
  # @todo Linux/Windows termination of strings??! Spec file?
  def to_s
    getHeader

    # Data, we print only the known frames, if you put more in here it's your own problem! 
    # TODO: Write a sanity checker for VPMs
    #
    # b0rked
    #0.upto( frames.to_i ) do |frame|
    #  [*@markers.keys].each do |marker|
    #    print eval( marker ).to_s + " "
    #    print "\n" if( @markers.keys.last.to_s =~ %r{#{marker.to_s}}i )
    #  end
    #end
    
    0.upto( frames.to_i ) do |i|
      puts getData( i )
    end

    ""
  end


  # Meta magic for get/set
  attr_accessor :name, :description, :frames, :frameTime, :markers
end


# Direct invocation, for manual testing beside rspec
if __FILE__ == $0
  
  # Simple test with one VPM segment
  fn    = "../sample/OneSegment.vpm"
  file  = File.open( fn ).readlines
  file.collect { |a| a.chomp! }

  segment     = file.shift.to_s.split(":").last.strip
  frames      = file.shift.to_s.split(":").last.strip
  frameTime   = file.shift.to_s.split(":").last.strip

  # Extract marker and unit names
  m           = file.shift.to_s.split(" ").collect { |i| i.downcase }
  u           = file.shift.to_s.split(" ").collect { |i| i.downcase }

  # Make a hash out of it
  markers     = Hash[ *m.zip( u ).flatten ]

  # This step will create get and set for e.g. xtran etc. 
  s = Segment.new segment, ""
  s.setMapping! markers

  # Set the rest
  s.frames    = frames
  s.frameTime = frameTime

  # p s.to_s

  # file contains now only data (one segment)
  file.each do |line|
    data = line.split(" ")
    markers.keys.each_with_index do |marker, index|
      eval( "s.#{marker.to_s} #{data[index]}" )
    end # markers

    p s.to_s
    exit
  end # file
end


# vim=ts:2

