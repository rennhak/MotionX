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

    @order              = Array.new                      # the order or our markers here (just for I/O order)a
    @markers            = Hash.new                       # our marker/unit hash here (just for convenience)
  end


  # = GetCoordinates! returns a set of e.g. XTRAN, YTRAN, ZTRAN coordinates in array in array form
  # [ [x,y,z], [x,y,z],... ] 
  # FIXME: Hardcoding
  def getCoordinates!
    return [ @xtran, @ytran, @ztran ].transpose
  end



  # = The initialize_copy method is necessary when this object is cloned or dup'd for various
  # reasons. (e.g. Marshal)
  def initialize_copy from
    @name, @description = from.name, from.description
    @order, @markers    = from.order, from.markers
  end

  # = setMapping! takes a segment hash and maps it internally
  # @param markers Markers is a key vector (array) which looks like this:
  #             XTRAN   YTRAN   ZTRAN   XROT    YROT    ZROT    XSCALE  YSCALE  ZSCALE
  #             Each value has NO newline or other special characters and is converted automatically
  #             to lower case.
  # @param units Units is a key vector (array) which looks like this:
  #             INCHES  INCHES  INCHES  DEGREES DEGREES DEGREES PERCENT PERCENT PERCENT
  #             Each value has NO newline or other special characters and is converted automatically
  #             to lower case.
  def setMapping! markers, units
    @order = markers

    # merge units and markers into a hash
    hash = Hash[ *markers.zip( units ).flatten ]

    # FIXME - below here
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
  # @returns Returns an array with the header lines, each slot is a new line
  def getHeader
    header = []

    delimiter = "\t"
    header << "Segment:#{delimiter}#{@name.upcase}"
    header << "Frames:#{delimiter}#{@frames}"
    header << "Frame Time:#{delimiter}#{@frameTime}"
    header << @order.collect{ |i| i.upcase }.join("\t").to_s                   # e.g. "XTRAN\tYTRAN\tZTRAN\tXROT\tYROT\tZROT\tXSCALE\tYSCALE\tZSCALE"
    
    @output = []
    @order.each { |markerName| @output << @markers[ markerName ].to_s  }
    header << @output.collect { |i| i.upcase }.join("\t").to_s                 # e.g. "INCHES\tINCHES\tINCHES\tDEGREES\tDEGREES\tDEGREES\tPERCENT\tPERCENT\tPERCENT"
    header
  end


  # = GetData returns the content of a frame at position index
  # @param index Index represenents one frame
  # @returns Returns an array with the desired values in the ORDER (@order) at INDEX (index)
  def getData index
    @order.dup.collect { |markerName| eval( "#{markerName.to_s}[#{index}]" ) } # e.g. ->  "#{xtran[index]} #{ytran[index]} #{ztran[index]} #{xrot[index]} #{yrot[index]} #{zrot[index]} #{xscale[index]} #{yscale[index]} #{zscale[index]}"
  end

  # == Dynamical method creation at run-time
  # @param method Takes the method header definition
  # @param code Takes the body of the method
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
    puts getHeader.join("\n")

    # TODO: Write a sanity checker for VPMs

    # frames.to_i starts with 1 we don't want that
    0.upto( frames.to_i - 1 ) do |i|
      # Construct the format string for printf (depending on how many marker names we have)
      # All markers are considered to be floats in the 4.6 format
      @format = []
      @order.length.to_i.times { @format << "%4.6f" }

      ( i == ( frames.to_i - 1 ) ) ? ( printf( @format.join(" ").to_s, *getData( i ) ) ) : ( printf( @format.join(" ").to_s + "\n", *getData( i ) ) )
    end
  end


  # Meta magic for get/set
  attr_accessor :name, :description, :frames, :frameTime, :markers, :order
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
  #markers     = Hash[ *m.zip( u ).flatten ]

  # This step will create get and set for e.g. xtran etc. 
  s = Segment.new segment, ""
  s.setMapping! m, u

  # Set the rest
  s.frames    = frames
  s.frameTime = frameTime

  # p s.to_s

  # file contains now only data (one segment)
  file.each do |line|
    data = line.split(" ")
    m.each_with_index do |marker, index|
      # Basically stuff the data into the adt
      eval( "s.#{marker.to_s} #{data[index]}" )
    end # markers

  end # file

  p s.to_s

end


# vim=ts:2

