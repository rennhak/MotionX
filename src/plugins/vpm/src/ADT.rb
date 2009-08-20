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

  # = initialize, inits the ADT class
  def initialize file # {{{
    @file       = file
    @segments   = []
    @body       = Body.new.body

    read!                           # read the given file and create dynamical objects
    computeExtraPoints!             # e.g. pt27, etc.

  end # end of initialize }}}


  # = initialize_copy method is necessary when this object is cloned or dup'd for various reasons. (e.g. Marshal)
  # @param from From needs a class name
  # @returns Self with instance_variables instanciated
  def initialize_copy from # {{{
    @file = from.file
    @segments = from.segments
  end # end of initialize_copy }}}


  # = getCoordinates returns a set of e.g. XTRAN, YTRAN, ZTRAN coordinates Array w/ subarrays
  # @param segment Segment needs a identifier of which segment is desired, e.g. "rwrb"
  # @returns An array in array form for a segment [ [x1,y1,z1], [x2,y2,z2],... ]
  def getCoordinates segment # {{{
    coords = eval( "@#{segment.to_s.downcase}" ).getCoordinates!
  end # end of getCoordinates }}}


  # = dynamical method creation at run-time
  # @param method Takes the method header definition
  # @param code Takes the body of the method
  def learn method, code # {{{
      eval <<-EOS
          class << self
              def #{method}; #{code}; end
          end
      EOS
  end # end of learn }}}


  # = read! function reads a given VPM file
  # After finishing the objects names in @segments exist as objects in this class as e.g. "@rwft" etc.
  # @param file File represents the path/file combination where to find the VPM file
  # @todo FIXME Checks and warnings if file is not readable. Also regarding vpm sanity.
  def read! file = @file # {{{

    data = File.open( file ).readlines    # read file and cut '\n's
    data.collect { |a| a.chomp! }

    ###
    # Split content into segments
    #####

    # How many segments do we have and what is their name? Also create for each segment a segment object.
    data.each do |l|
      if l.to_s =~ %r{Segment:}i
        s = l.split(":").last.strip.to_s.downcase
        @segments << s

        # Generate a variable for each segment
        self.instance_variable_set( "@#{s.to_s}", Segment.new( s, "" ) )     # same idea as in Segment.rb

        # FIXME: Add meta information for segments

        learn( "#{s.to_s}", "return @#{s.to_s}" ) # Getter method
      end
    end

    # Split contents along the "Segment:" lines into a segment objects the delete_if removes the first empty element
    segments = data.dup.join("\n").to_s.split("Segment:").delete_if { |s| s.empty? }.collect { |s| "Segment:"+s.to_s }
    segments.each { |s| processSegment( s ) }                                # this will gen various segments

    # FIXME: Check if read succeeded
  end # end of read! }}}


  # = processSegment takes a segment string and returns a segment object, but also sets the object.
  # @param string String is one segment ans one string incl. newlines etc.
  # @returns Returns a Segment object generated from the given string e.g. "Segment: RWFT...." -> @rwft = Segment.new...
  # @warning First line in the string needs to be a segment definition. The Segment section needs to
  #          validate specification otherwise this function will fail. Run vpmcheck first.
  def processSegment string # {{{
    data = string.split("\n")

    # Get meta information
    segment     = data.shift.to_s.split(":").last.strip
    frames      = data.shift.to_s.split(":").last.strip
    frameTime   = data.shift.to_s.split(":").last.strip

    # Extract marker and unit names
    m           = data.shift.to_s.split(" ").collect { |i| i.downcase }
    u           = data.shift.to_s.split(" ").collect { |i| i.downcase }

    # Set marker mappings and other variables as instance variables
    eval( "@#{segment.downcase}" ).setMapping!( m, u )
    eval( "@#{segment.downcase}" ).frames    = frames
    eval( "@#{segment.downcase}" ).frameTime = frameTime

    # Only data (one segment!) left
    data.each do |line|
      d = line.split(" ")
      m.each_with_index { |marker, index| eval( "@#{segment.downcase}.#{marker.to_s} << #{d[index]}" ) }
    end # end of data

    eval( "@#{segment.downcase}" )
  end # end of processSegment }}}


  #= getNewSegment! generates a new empty segment with the same frame, frametime, and markers + order as existing ones
  # @param name A string representing the name of the segment, e.g. "rwft". It will be used as instance variable e.g. "@rwft"
  # @param description A string describing the point's meaning on the body. E.g. Rear Waist Forward Top half..." etc.
  # @returns A segment object with the name and description. Also sets a instance_variable with the same name and data
  def getNewSegment! name, description # {{{
    new = @rwrb.fork( name, description )   # FIXME: Hardcoding

    # Generate a variable for each segment
    self.instance_variable_set( "@#{name.to_s}", new )     # same idea as in Segment.rb 

    # TODO: Add meta information for segments

    learn( "#{name.to_s}", "return @#{name.to_s}" ) # Getter function

    new
  end # }}}


  # = computeExtraPoints does exactly as the name suggests. See S. Kudoh Thesis (p. 109) for more info on this.
  def computeExtraPoints! # {{{

    %w[pt24 pt25 pt26 pt27 pt28 pt29 pt30 pt31 pt32].each { |var| getNewSegment!( var.to_s, "" ) }         # Generate new segments

    # Standard Points from S. Kudoh Thesis
    @pt24 = ( @lfhd + @lbhd + @rfhd + @rbhd ) / 4
    @pt25 = ( @lsho + @rsho )                 / 2
    @pt26 = ( @lwra + @lwrb )                 / 2
    @pt27 = ( @rwra + @rwrb )                 / 2
    @pt28 = ( @lfwt + @lbwt )                 / 2
    @pt29 = ( @rfwt + @rbwt )                 / 2
    @pt30 = ( @pt28 + @pt29 )                 / 2
    @pt31 = ( @pt25 + ( @pt30 * 2 ) )         / 3     # FIXME: Depends on normalization, see Motion Viewer code
  end # }}}


  # = getSlopeForm returns a solution of the following:
  #   Two points p1 (x,y,z) and p2 (x2,y2,z2) span a line in 2D space.
  #   The slope form also known as f(x) =>  y = m*x + t 
  #   m = DeltaY / DeltaX  ; where DeltaY is the Y2 - Y1 ("steigung")
  # @param array1 Set of coordinates Point A
  # @param array2 Set of coordinates Point B
  # @returns Array, containing m and t for the slope form equasion
  # @warning FIXME: Z coordinate is only neglegted and this needs to be normally compensated
  def getSlopeForm array1, array2 # {{{
    x1, y1, z1      = *array1
    x2, y2, z2      = *array2

    deltaX, deltaY  = ( x2 - x1 ), ( y2 - y1 )
    m               = deltaY / deltaX
    t               = y1 - ( m * x1 )

    [ m, t ]
  end # end of getSlopeForm }}}


  # = getIntersectionPoint returns a solution for the following:
  #   Two lines in slope intersection form f1 y = m*x + t  and f2 ...
  #   intersection in a point (or not -> the intersection with the origin is returned) and this point is returned.
  # @param array1 Array, with m and t of a line in slope form
  # @param array2 Array, with m and t of a line in slope form
  # @returns Array containing 2D point of intersection
  def getIntersectionPoint array1, array2 # {{{
    m1, t1 = *array1
    m2, t2 = *array2

    #     m1*x + t1   = m2*x + t2   | -m2*x - t1
    # <=> m1*x - m2*x = t2 - t1
    # <=> (m1-m2)*x   = t2 - t1     | / (m1-m2)
    # <=>         x   = (t2-t1) / (m1-m2)
    x       = ( t2 - t1 ) / ( m1 - m2 )
    y1, y2  = ( m1 * x + t1 ), ( m2 * x + t2 )

    # FIXME: This error occurs due to many decimals after the comma... use sprintf
    # FIXME: Assertion
    # raise ArgumentError, "Y1 and Y2 of the equasion has to be same. Something is b0rked. (,#{y1.to_s}' *** ,#{y2.to_s}')" unless y1 == y2

    [x,y1]
  end # end of getIntersectionPoint }}}


  # = determinat returns a solution for the following:
  #   Given two lines in slope intersection form f1 y = m*x +t and f2...
  #   the determinant is ad - bc ; three cases:
  #   -1  := No solution
  #    0  := One
  #    1  := Unlimited (you can invert it)
  def determinat array1, array2 # {{{
    # FIXME write a class for matrix functionality
  end # end of determinat }}}


  # = check parses a VPM file and looks for errors. In case of error it returns false
  def valid? file = @file # {{{
    

  end # end of valid? }}}


  # = getPhi takes two segements and performs a simple golden ratio calculation for each coordinate pair
  #   A good reference would be \varphi = \frac{1 + \sqrt{5}}{2} \approx 1.61803339 \ldots
  # @param segment1 Expects a valid segment name, e.g. rwft
  # @param segment1 Expects a valid segment name, e.g. lwft
  # @returns Hash, containing reference Phi, calculated Phi from the segments and the difference, e.g. "[ 1.61803339.., 1.59112447, 0.2... ]"
  def getPhi segment1, segment2, frame = nil # {{{
    results                      = {}
    xtranPhi, ytranPhi, ztranPhi = [], [], []

    # calculate a reference phi
    results[ "phi" ]  = ( ( 1 + Math.sqrt(5) ) / 2 )

    # get Coordinate Arrays, e.g. [ [ ..., ..., ... ], [ ... ], ... ]
    s1, s2            = eval( "@#{segment1.to_s}.getCoordinates!" ), eval( "@#{segment2.to_s}.getCoordinates!" )

    # push all x, y and z values to the subarrays in #{$x}tranPhi
    s1.each_with_index { |array, index| x, y, z = *array ; %w[x y z].each { |var| eval( "#{var.to_s}tranPhi << [ #{var} ]" ) } }
    s2.each_with_index { |array, index| x, y, z = *array ; %w[x y z].each { |var| eval( "#{var.to_s}tranPhi[#{index}] << #{var}" ) } }

    # calculate phi for each timeframe
    xtranPhi.collect! { |a, b| ( ( a + b ) / a ) }
    ytranPhi.collect! { |a, b| ( ( a + b ) / a ) }
    ztranPhi.collect! { |a, b| ( ( a + b ) / a ) }

    results[ "xtranPhi" ] = ( frame.nil? ) ? ( xtranPhi ) : ( xtranPhi[ frame ] )
    results[ "ytranPhi" ] = ( frame.nil? ) ? ( ytranPhi ) : ( ytranPhi[ frame ] )
    results[ "ztranPhi" ] = ( frame.nil? ) ? ( ztranPhi ) : ( ztranPhi[ frame ] )

    results
  end # end of getPhi }}}

  # = write dumps a given VPM data into a file
  # @param file Expects a string with a full URI as path/file combination
  # FIXME: This method is b0rked because the Segment.rb to_s function uses printf instead of returning proper strings.
  # @returns Boolean, true if write succeeded and false if not.
  def write file = "/tmp/MotionX_Output.vpm" # {{{
    @result = []

    # rendering of each segment is done in Segment.rb
    @segments.each { |segmentName| @result << eval( "@#{segmentName.to_s}" ).to_s }

    File.open( file, File::CREAT|File::TRUNC|File::RDWR, 0644) { |f| f.write( @result.join("\n") ) }
  end # end of write }}}


  # = getTurningPoints returns a set of values after turning point calculation (B. Rennhak's Method '09)
  # takes four segments ( a,b,c,d - 2 for each line (a+b) (c+d) ) one segment for
  # @param segment1a Name of segment which together with segment1b builds a 3D line
  # @param segment1b Name of segment which together with segment1a builds a 3D line
  # @param segment2a Name of segment which together with segment2b builds a 3D line
  # @param segment2b Name of segment which together with segment2a builds a 3D line
  # @param center Name of segment which is our coordinate center for measurement and projection (3D->2D)
  # @returns Array, containing the points after the calculation
  # @warning FIXME: This thing is too slow, speed it up
  def getTurningPoints segment1 = "pt27", segment2 = "relb", segment3 = "pt26", segment4 = "lelb", center = "p30" # {{{

    #####
    #
    # Reference case
    # e.g. S. Kudoh Thesis, Page 109, VPM File used "Aizu_Female.vpm"
    #
    # Center of Coordinate System:  p30
    # Right Arm:                    p27 and p9 ("relb")
    # Left Arm:                     p26 and p5 ("lelb")
    #
    ###########

    # Easy handling
    pt30 = @pt30
    pt27 = @pt27
    pt9  = @relb
    pt26 = @pt26
    pt5  = @lelb

    # Make coords relative to p30 not global -- not normalized
    pt27new           = pt27 - pt30
    pt9new            = pt9  - pt30
    slopeCoordsVars1  = []

    pt26new           = pt26 - pt30
    pt5new            = pt5  - pt30
    slopeCoordsVars2  = []

    [ pt27new.getCoordinates!.zip( pt9new.getCoordinates! ) ].each do |array|
      array.each do |point27Array, point9Array|
        slopeCoordsVars1 << getSlopeForm( point27Array, point9Array )
      end
    end

    [ pt26new.getCoordinates!.zip( pt5new.getCoordinates! ) ].each do |array|
      array.each do |point26Array, point5Array|
        slopeCoordsVars2 << getSlopeForm( point26Array, point5Array )
      end
    end 

    points = []

    # Determine the intersection point of the two lines
    [ slopeCoordsVars1.zip( slopeCoordsVars2 ) ].each do |array|
      array.each do |line1, line2|  # line1 == [m, t]   --> f(x) y = m*x + t
        points << getIntersectionPoint( line1, line2 )
      end
    end

    pt30Coords = pt30.getCoordinates!
    final = []
    n = 0
    points.each do |p1, p2|
      n += 1

      x = pt30Coords[n].shift
      y = pt30Coords[n].shift
      z = pt30Coords[n].shift

      length = Math.sqrt( (x*x) + (y*y) + (z*z) )

      final << [ "#{n.to_s}, #{ ((p1-x)/length).to_s}, #{((p2-y)/length).to_s}" ]
    end

    points
  end # end of getTurningPoints }}}


  # = writeCSV takes various 
  def writeCSV
  end

  attr_accessor :segments, :file, :body
end # end of ADT class }}}


# = Direct invocation, for manual testing besides rspec
if __FILE__ == $0

  adt = ADT.new( "../sample/Aizu_Female.vpm" )

  points = adt.getTurningPoints( "p27", "relb", "p26", "lelb", "p30"  )

  f = File.open("/tmp/results.csv", "w")
  f.write( "index, x, y\n")
  #n = 0
  #pt30Coords = pt30.getCoordinates!

  points.each do |n, p1, p2|
  #  n += 1
  #  next if( n < 990 )
  #  next if( n > 1040 )

    #next if( n < 1100 )
    #next if( n > 1166 )

  #  x = pt30Coords[n].shift
  #  y = pt30Coords[n].shift
  #  z = pt30Coords[n].shift


  #  length = Math.sqrt( (x*x) + (y*y) + (z*z) )

    f.write( "#{n.to_s}, #{p1.to_s}, #{p2.to_s}\n" )
  end
  f.close

  # = PHI Calculation
  # x = adt.getPhi( "pt24", "pt30", 10 )["ytranPhi"]
  # p x = adt.getPhi( "pt26", "lsho", 10 )
  # @results = []
  # if( x.is_a?(Numeric) )
  #   p x
  # else
  #   x.each_with_index { |val, index| @results << "#{index},#{( 1.61803398874989 - val ).abs}\n" }
  #   File.open( "/tmp/foo", "w" ) { |f| f.write( "x,y\n" ); f.write( @results.to_s ) }
  # end

end # end of if __FILE__ == $0

# vim=ts:2
