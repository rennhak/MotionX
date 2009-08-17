#!/usr/bin/ruby
#

###
#
# File: ADT.rb
#
######


###
#
# (c) 2009, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       ADT.rb
# @author     Bjoern Rennhak
# @since      Fri Jul  3 05:23:16 JST 2009
# @version    0.0.1
# @copyright  See COPYRIGHT file for details.
#
#######


require 'Segment.rb'
require 'Description.rb'

###
#
# @class   ADT
# @author  Bjoern Rennhak
# @brief   ADT is a internal Abstract Data Type class holding the information of the VPM file for read and writes.
# @details The ADT class is used to hold all possible VPM information, thus called Abstract Data
#          Type. The usage is plugin internal only and is later conencted to e.g. MotionX via the
#          Mapping.rb handler. If you write another Mapping.rb you could probably generate to other
#          file formats.
#
#######
class ADT
  def initialize file 
    @file = file
    @segments   = Array.new
    @body       = Description.new.body

    read!                           # read the given file and create dynamical objects

  end

  
  # = GetCoordinates returns a set of e.g. XTRAN, YTRAN, ZTRAN coordinates in array in array form
  # for a segment
  # [ [x1,y1,z1], [x2,y2,z2],... ]
  # @param segment Segment needs a identifier of which segment is desired, e.g. "rwrb"
  def getCoordinates segment

    coords = eval( "@#{segment.to_s.downcase}" ).getCoordinates!
    p coords

    exit
  end


  # = The initialize_copy method is necessary when this object is cloned or dup'd for various
  # reasons. (e.g. Marshal)
  def initialize_copy from
    @file = from.file
    @segments = from.segments
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

  # = Read reads a given VPM file
  # @param file File represents the path/file combination where to find the VPM file
  # After finishing the objects names in @segments exist as objects in this class as e.g. "@rwft"
  # etc.
  # @todo Checks and warnings if file is not readable. Also regarding vpm sanity.
  def read! file = @file

    # read file and cut '\n's
    data = File.open( file ).readlines
    data.collect { |a| a.chomp! }

    ###
    # Split content into segments
    # 1.) How many segments do we have and what is their name? Also create for each segment a
    # segment object.
    data.each do |l|
      if l.to_s =~ %r{Segment:}i
        s = l.split(":").last.strip.to_s.downcase
        @segments << s

        # generate a variable for each segment
        self.instance_variable_set( "@#{s.to_s}", Segment.new( s, "" ) )     # same idea as in Segment.rb TODO: Add meta information for segments

        # TODO: doesn't ruby have a better way for this? --- attr??
        learn( "#{s.to_s}", "return @#{s.to_s}" ) # getter
      end
    end

    # 2.) Split contents along the "Segment:" lines into a segment objects
    # the delete_if removes the first empty element
    segments = data.dup.join("\n").to_s.split("Segment:").delete_if { |s| s.empty? }.collect { |s| "Segment:"+s.to_s }
    segments.each { |s| processSegment( s ) }                   # this will gen various segments

    # TODO: Check if read succeeded
  end


  # = ProcessSegment takes a segment string and returns a segment object, but also sets the object.
  # @param string String is one segment ans one string incl. newlines etc.
  # @returns Returns a Segment object generated from the given string
  # e.g. "Segment: RWFT...." -> @rwft = Segment.new...
  # @warning First line in the string needs to be a segment definition. The Segment section needs to
  # validate specification otherwise this function will fail. Run vpmcheck first.
  def processSegment string
    data = string.split("\n")

    # Get meta
    segment     = data.shift.to_s.split(":").last.strip
    frames      = data.shift.to_s.split(":").last.strip
    frameTime   = data.shift.to_s.split(":").last.strip

    # Extract marker and unit names
    m           = data.shift.to_s.split(" ").collect { |i| i.downcase }
    u           = data.shift.to_s.split(" ").collect { |i| i.downcase }

    eval( "@#{segment.downcase}" ).setMapping!( m, u )

    # Set the rest
    eval( "@#{segment.downcase}" ).frames    = frames
    eval( "@#{segment.downcase}" ).frameTime = frameTime

    # now only data (one segment)
    data.each do |line|
      d = line.split(" ")
      m.each_with_index do |marker, index|
        # Basically stuff the data into the adt
        eval( "@#{segment.downcase}.#{marker.to_s} #{d[index]}" )
      end # markers
    end # data

    #p eval( "@#{segment.downcase}" ).to_s
    return eval( "@#{segment.downcase}" )
  end




  # = Check checks a given VPM file
  def check file = @file
  end


  # = Write writes a given VPM file
  # FIXME: This method is b0rked because the Segment.rb to_s function uses printf instead of
  # returning proper strings.
  def write file = "/tmp/MotionX_Output.vpm"
    @result = []

    @segments.each do |segmentName|
      @result << eval( "@#{segmentName.to_s}" ).to_s
    end

    File.open( file, File::CREAT|File::TRUNC|File::RDWR, 0644) { |f| f.write( @result.join("\n") ) }
  end


  attr_accessor :segments, :file, :body
  # attr_reader :segments
  # attr_writer
end


# Direct invocation, for manual testing beside rspec
if __FILE__ == $0

  adt = ADT.new( "../sample/Aizu_Female.vpm" )

  #adt.getCoordinates( "rwrb" )

  # p adt.segments
  # p adt.rfwt.xtran

  # FIXME: adt.write

end


# vim=ts:2

