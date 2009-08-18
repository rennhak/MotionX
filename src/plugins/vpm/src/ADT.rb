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
require 'Body.rb'

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
    @body       = Body.new.body

    read!                           # read the given file and create dynamical objects
    computeExtraPoints!             # e.g. pt27, etc.
  end

  
  # = GetCoordinates returns a set of e.g. XTRAN, YTRAN, ZTRAN coordinates in array in array form
  # for a segment
  # [ [x1,y1,z1], [x2,y2,z2],... ]
  # @param segment Segment needs a identifier of which segment is desired, e.g. "rwrb"
  def getCoordinates segment
    coords = eval( "@#{segment.to_s.downcase}" ).getCoordinates!
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

        # TODO: doesn't ruby have a better way for this? --- attr in functions?
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
        eval( "@#{segment.downcase}.#{marker.to_s} << #{d[index]}" )
      end # markers
    end # data

    #p eval( "@#{segment.downcase}" ).to_s
    return eval( "@#{segment.downcase}" )
  end


  #= getNewSegment! generates a new empty segment with the same frame, frametime, and markers + order as existing ones
  # @returns A segment object with the name and description. Also sets a instance_variable with the same name and data
  def getNewSegment! name, description
    new = @rwrb.fork( name, description )   # FIXME: Hardcoding

    # generate a variable for each segment
    self.instance_variable_set( "@#{name.to_s}", new )     # same idea as in Segment.rb TODO: Add meta information for segments

    # TODO: doesn't ruby have a better way for this? --- attr in functions?
    learn( "#{name.to_s}", "return @#{name.to_s}" ) # getter

    return new
  end


  # = computeExtraPoints does exactly as the name suggests. See Kudoh Thesis for more info on this.
  # (p. 109)
  def computeExtraPoints!

    # pt32 -> Bellybutton

    %w[pt24 pt25 pt26 pt27 pt28 pt29 pt30 pt31 pt32].each { |var| getNewSegment!( var.to_s, "" ) }         # Generate new segments

    @pt24 = ( @lfhd + @lbhd + @rfhd + @rbhd ) / 4
    @pt25 = ( @lsho + @rsho ) / 2
    @pt26 = ( @lwra + @lwrb ) / 2
    @pt27 = ( @rwra + @rwrb ) / 2
    @pt28 = ( @lfwt + @lbwt ) / 2
    @pt29 = ( @rfwt + @rbwt ) / 2
    @pt30 = ( @pt28 + @pt29 ) / 2
    @pt31 = ( @pt25 + ( @pt30 * 2 ) ) / 3
    # @pt32 = 
  end


  # = getSlopeForm returns a solution of the following:
  # Two points p1 (x,y,z) and p2 (x2,y2,z2) span a line in 2D space.
  # The slope form also known as f(x) =>  y = m*x + t 
  # m = DeltaY / DeltaX  ; where DeltaY is the Y2 - Y1 ("steigung")
  # @param array1 Set of coordinates Point A
  # @param array2 Set of coordinates Point B
  # @returns Array containing m and t for the slope form equasion
  # @warning FIXME: Z coordinate is only neglegted and this needs to be normally compensated
  def getSlopeForm array1, array2
    x1, y1, z1  = *array1
    x2, y2, z2  = *array2

    deltaY      = y2 - y1
    deltaX      = x2 - x1
    m           = deltaY / deltaX

    t           = y1 - ( m * x1 )

    return [ m, t ]
  end

  # = getIntersectionPoint returns a solution for the following:
  # Two lines in slope intersection form f1 y = m*x + t  and f2 ...
  # intersection in a point (or not -> the intersection with the origin is returned) and this point
  # is returned.
  # @param array1 Array with m and t of a line in slope form
  # @param array2 Array with m and t of a line in slope form
  # @returns Array containing 2D point of intersection
  def getIntersectionPoint array1, array2
    m1, t1 = *array1
    m2, t2 = *array2

    # m1*x + t1 = m2*x + t2 <=> ..
    x   = ( t2 - t1 ) / ( m1 - m2 )
    y1  = m1 * x + t1
    y2  = m2 * x + t2

    # FIXME: This error occurs due to many decimals after the comma... use sprintf -- use
    # assertions anyway! 
    # raise ArgumentError, "Y1 and Y2 of the equasion has to be same. Something is b0rked. (,#{y1.to_s}' *** ,#{y2.to_s}')" unless y1 == y2

    return [x,y1]
  end
  

  # = determinat returns a solution for the following:
  # Given two lines in slope intersection form f1 y = m*x +t and f2...
  # the determinant is ad - bc ; three cases:
  # -1  := No solution
  #  0  := One
  #  1  := Unlimited (you can invert it)
  def determinat array1, array2
    # FIXME write a class for matrix functionality
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

  #  puts "pt30 = "
  #  p adt.pt30.getCoordinates!.first
  #
  #  puts "pt24 = "
  #  p adt.pt24.getCoordinates!.first
  #
  #  puts "( ( pt24.y + pt30.y ) / pt30.y )"
  #  res = ( ( adt.pt24 + adt.pt30 ) / adt.pt24 ).ytran
  #  final = 0
  #  res.each { |n| final += n } ; final = final / res.length
  #  p 1.6180339887 - final

  ################
  #
  # p30 origin
  # p27 and p9      ||    p26 and p5
  #

  # Easy handling
  pt30 = adt.pt30
  pt27 = adt.pt27
  pt9  = adt.relb
  pt26 = adt.pt26
  pt5  = adt.lelb

  # Make coords relative to p30 not global -- not normalized
  pt27new           = pt27 - pt30
  pt9new            = pt9  - pt30
  slopeCoordsVars1  = []

  pt26new           = pt26 - pt30
  pt5new            = pt5  - pt30
  slopeCoordsVars2  = []

  [ pt27new.getCoordinates!.zip( pt9new.getCoordinates! ) ].each do |array|
    array.each do |point27Array, point9Array|
      #puts "Point 27:"
      #p point27Array
      #puts "Point 9:"
      #p point9Array
      #puts "m and t are:"
      slopeCoordsVars1 << adt.getSlopeForm( point27Array, point9Array )
    end
  end


  [ pt26new.getCoordinates!.zip( pt5new.getCoordinates! ) ].each do |array|
    array.each do |point26Array, point5Array|
      #puts "Point 26:"
      #p point26Array
      #puts "Point 5:"
      #p point5Array
      #puts "m and t are:"
      slopeCoordsVars2 << adt.getSlopeForm( point26Array, point5Array )
    end
  end 
  

  points = []

  # Determine the intersection point of the two lines
  [ slopeCoordsVars1.zip( slopeCoordsVars2 ) ].each do |array|
    array.each do |line1, line2|  # line1 == [m, t]   --> f(x) y = m*x + t
      points << adt.getIntersectionPoint( line1, line2 )
    end
  end


  f = File.open("/tmp/results.csv", "w")
  f.write( "index, x, y\n")
  n = 0
  pt30Coords = pt30.getCoordinates!
  points.each do |p1, p2|
    n += 1
    next if( n < 0 )
    next if( n > 100 )

    #next if( n < 1100 )
    #next if( n > 1166 )

    x = pt30Coords[n].shift
    y = pt30Coords[n].shift
    z = pt30Coords[n].shift

    length = Math.sqrt( (x*x) + (y*y) + (z*z) )

    f.write( "#{n.to_s}, #{ ((p1-x)/length).to_s}, #{((p2-y)/length).to_s}\n" )
  end
  f.close

  # find derivatives (or approx.) of turningpoints
 # index = 0
 # points.each do |p1x, p1y|
 #     p "Index: " + index.to_s
 #     p2x, p2y = *points[ index + 1 ]
 #     p "P1X: " + p1x.to_s
 #     p "P1Y: " + p1y.to_s
 #     p "P2X: " + p2x.to_s
 #     p "P2Y: " + p2y.to_s
 #     index += 1
 #     
 #     deltaX = p2x - p1x
 #     deltaY = p2y - p1y
 #     m      = deltaY / deltaX
 #     
 #     p "m = #{m.to_s}  -- Frame: #{index.to_s}"
 #     STDIN.gets

 # end
 # 

end # end of if __FILE__ == $0


# vim=ts:2

