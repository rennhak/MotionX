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

    @order              = Array.new                      # the order or our markers here (just for I/O order)
    @markers            = Hash.new                       # our marker/unit hash here (just for convenience)
  end


  # = GetCoordinates! returns a set of e.g. XTRAN, YTRAN, ZTRAN coordinates in array in array form
  # [ [x,y,z], [x,y,z],... ] 
  # FIXME: Hardcoding
  def getCoordinates!
    return [ @xtran, @ytran, @ztran ].transpose
  end


  # = + Operator expects another object of the type segment
  def + ( other )
    ownCoordinates    = self.getCoordinates!

    if other.is_a?( Numeric )
      ownCoordinates    = self.getCoordinates!

      # Clone self and push new coords and name
      newCoordinates = self.fork( "(_" + self.name.to_s + "_+_" + other.to_s + "_)" )

      ownCoordinates.each do |array1|
        x1, y1, z1 = *array1

        newX, newY, newZ = (x1+other), (y1+other), (z1+other)

        newCoordinates.xtran << newX
        newCoordinates.ytran << newY
        newCoordinates.ztran << newZ
      end
    else
      otherCoordinates  = other.getCoordinates!                       # we get an array of coords [x,y,z]
      ownCoordinates    = self.getCoordinates!

      # Clone self and push new coords and name
      newCoordinates = self.fork( "(_" + self.name.to_s + "_+_" + other.name.to_s + "_)" )

      [ ownCoordinates, otherCoordinates ].transpose.each do |array1, array2|
        x1, y1, z1 = *array1
        x2, y2, z2 = *array2

        newX, newY, newZ = (x1+x2), (y1+y2), (z1+z2)

        newCoordinates.xtran << newX
        newCoordinates.ytran << newY
        newCoordinates.ztran << newZ
      end
    end

    return newCoordinates
  end

  # = - Operator expects another object of the type segment
  def - ( other )
    ownCoordinates    = self.getCoordinates!

    if other.is_a?( Numeric )
      # Clone self and push new coords and name
      newCoordinates = self.fork( "(_" + self.name.to_s + "_-_" + other.to_s + "_)" )

      ownCoordinates.each do |array1|
        x1, y1, z1 = *array1

        newX, newY, newZ = (x1-other), (y1-other), (z1-other)

        newCoordinates.xtran << newX
        newCoordinates.ytran << newY
        newCoordinates.ztran << newZ
      end
    else
      otherCoordinates  = other.getCoordinates!                       # we get an array of coords [x,y,z]

      # Clone self and push new coords and name
      newCoordinates = self.fork( "(_" + self.name.to_s + "_-_" + other.name.to_s + "_)" )

      [ ownCoordinates, otherCoordinates ].transpose.each do |array1, array2|
        x1, y1, z1 = *array1
        x2, y2, z2 = *array2

        newX, newY, newZ = (x1-x2), (y1-y2), (z1-z2)

        newCoordinates.xtran << newX
        newCoordinates.ytran << newY
        newCoordinates.ztran << newZ
      end
    end

    return newCoordinates
  end

  # = * Operator expects another object of the type segment
  def * ( other )
    ownCoordinates    = self.getCoordinates!

    if other.is_a?( Numeric )

      # Clone self and push new coords and name
      newCoordinates = self.fork( "(_" + self.name.to_s + "_*_" + other.to_s + "_)" )

      ownCoordinates.each do |array1|
        x1, y1, z1 = *array1

        newX, newY, newZ = (x1*other), (y1*other), (z1*other)

        newCoordinates.xtran << newX
        newCoordinates.ytran << newY
        newCoordinates.ztran << newZ
      end
    end

    if other.is_a?( Segment )
      otherCoordinates  = other.getCoordinates!                       # we get an array of coords [x,y,z]

      # Clone self and push new coords and name
      newCoordinates = self.fork( "(_" + self.name.to_s + "_*_" + other.name.to_s + "_)" )

      [ ownCoordinates, otherCoordinates ].transpose.each do |array1, array2|
        x1, y1, z1 = *array1
        x2, y2, z2 = *array2

        newX, newY, newZ = (x1*x2), (y1*y2), (z1*z2)

        newCoordinates.xtran << newX
        newCoordinates.ytran << newY
        newCoordinates.ztran << newZ
      end
    end

    # if we want to apply an array(frames) of scalars to the segment vector (x,y,z) for all frames f 
    if other.is_a?( Array )
      # Clone self and push new coords and name
      newCoordinates = self.fork( "(_" + self.name.to_s + "_*_" + "scalar_)" )

      cnt = 0
      ownCoordinates.each do |array1|
        x1, y1, z1  = *array1
        scalar      = other[cnt]

        newX, newY, newZ = (x1*scalar), (y1*scalar), (z1*scalar)

        newCoordinates.xtran << newX
        newCoordinates.ytran << newY
        newCoordinates.ztran << newZ
        cnt += 1
      end
    end

    return newCoordinates
  end

  # = / Operator expects another object of the type segment
  def / ( other )
    ownCoordinates    = self.getCoordinates!

    if other.is_a?( Numeric )
      # Clone self and push new coords and name
      newCoordinates = self.fork( "(_" + self.name.to_s + "_/_" + other.to_s + "_)" )

      ownCoordinates.each do |array1|
        x1, y1, z1 = *array1

        newX, newY, newZ = (x1/other), (y1/other), (z1/other)

        newCoordinates.xtran << newX
        newCoordinates.ytran << newY
        newCoordinates.ztran << newZ

      end
    else
      otherCoordinates  = other.getCoordinates!                       # we get an array of coords [x,y,z]

      # Clone self and push new coords and name
      newCoordinates = self.fork( "(_" + self.name.to_s + "_/_" + other.name.to_s + "_)" )

      [ ownCoordinates, otherCoordinates ].transpose.each do |array1, array2|
        x1, y1, z1 = *array1
        x2, y2, z2 = *array2

        newX, newY, newZ = (x1/x2), (y1/y2), (z1/z2)

        newCoordinates.xtran << newX
        newCoordinates.ytran << newY
        newCoordinates.ztran << newZ
      end
    end # end of other.is_a(Fixnum)

    return newCoordinates
  end

  # = dot_product returns as the name suggest the dot product for two vectors (3D)
  # d(u,v) =  (u).x * (v).x + (u).y * (v).y + (u).z * (v).z
  # @param other Segment
  # @returns Array of scalars of length self.frames
  # Write a dot operator for segment
  def dot_product( other ) # {{{
    ownCoordinates    = self.getCoordinates!

    if other.is_a?( Segment )
      otherCoordinates  = other.getCoordinates!                       # we get an array of coords [x,y,z]

      dot_products      = []

      [ ownCoordinates, otherCoordinates ].transpose.each do |array1, array2|
        x1, y1, z1 = *array1
        x2, y2, z2 = *array2

        dot_products <<  ( (x1*x2) + (y1*y2) + (z1*z2) )
      end

    else
      raise ArgumentError, "How can you do a dot product of something that is not a segment class ?"
    end # end of other.is_a(Segment)

    return dot_products
  end # of def dot_product }}} 


  # = norms returns as the name suggest the norm (length of all vectors) for self norm = sqrt(dot(v,v))
  # @returns Array of scalars of length self.frames representing the norms for all entries
  def norms # {{{
    norm_scalars = []
    # dot( self, self )
    self.dot_product( self ).each do |pre_norm|
      norm_scalars << Math.sqrt( pre_norm )
    end

    return norm_scalars
  end # of def norm(other) }}}


  # = distance_to returns the distance between two vectors ( distance( u,v ) = norm( u-v ) )
  # @param other Segment
  # @returns Array of scalars
  # More info search for "Distance between Lines and Segments with their Closest Point of Approach"
  # e.g. http://softsurfer.com/Archive/algorithm_0106/algorithm_0106.htm
  def distance_to( other ) # {{{
    if other.is_a?( Segment )
      new       = self - other      # segment(self) - segment(other)
    else
      raise ArgumentError, "How can you do a distance calculation if the other is not a segment?"
    end # end of other.is_a(Segment)

    return new.norms
  end # of def distance }}}

  
  # = Determinat
  # @param a scalar
  # ...
  def determinant( a, b, c, d, e, f, g, h, i ) # {{{
    # http://en.wikipedia.org/wiki/Triangle#Using_coordinates
    # det (A) = aei + bfg + cdh - afh - bdi - ceg (rule of sarrus)
    #       _         _
    #      |  a  b  c  |
    #  A = |  d  e  f  |
    #      |_ g  h  i _|
 
    return ( (a*e*i) + (b*f*g) + (c*d*h) - (a*f*h) - (b*d*i) - (c*e*g) )
  end # of determinant }}}


  # = area_of_triangle of three segments (self, p1, p2)
  # @param p1 Segment
  # @param p2 Segment
  # @returns Array of area values for all frames f
  def area_of_triangle( p1, p2 ) # {{{
   
    ownCoordinates    = self.getCoordinates!
    areas             = []

    if p1.is_a?( Segment ) && p2.is_a?( Segment )
      p1Coordinates     = p1.getCoordinates!
      p2Coordinates     = p2.getCoordinates!

      [ ownCoordinates, p1Coordinates, p2Coordinates ].transpose.each do |array1, array2, array3|
        x1, y1, z1 = *array1
        x2, y2, z2 = *array2
        x3, y3, z3 = *array3
        
        # In three dimensions, the area of a general triangle {A = (xA, yA, zA), B = (xB, yB, zB) and C = (xC, yC, zC)} is the Pythagorean sum of the areas
        # of the respective projections on the three principal planes (i.e. x = 0, y = 0 and z = 0)
        #
        #   area = 0.5 * Math.sqrt(   det(MatrixA)^2 + det(MatrixB)^2 + det(MatrixC)^2   )
        #
        #             |  x1 x2 x3  |                |  y1 y2 y3  |             |  z1 z2 z3  |
        #   MatrixA = |  y1 y2 y3  |      MatrixB = |  z1 z2 z3  |   MatrixC = |  x1 x2 x3  |
        #             |_  1  1  1 _|                |_ 1  1  1  _|             |_ 1  1  1  _|
        #
        # FIXME: Write det and matrix abstractions
        
        detMatrixA = determinant( x1, x2, x3, y1, y2, y3, 1, 1, 1 )
        detMatrixB = determinant( y1, y2, y3, z1, z2, z3, 1, 1, 1 )
        detMatrixC = determinant( z1, z2, z3, x1, x2, x3, 1, 1, 1 )
  
        areas << ( 0.5 * ( Math.sqrt( (detMatrixA**2) + (detMatrixB**2) + (detMatrixC**2) ) ) )
      end
    else
      raise ArgumentError, "How can you do a dot product of something that is not a segment class ? (NotImplementedError)"
    end # end of other.is_a(Segment)

    return areas
  end # of def area_of_triangle }}}


  # = Forks self object and just cleans out data which is then used to push some results like "add"
  # @returns Segment object like self w/o data and new name
  def fork( name, description = "" )
    new = Segment.new( name, description )
    new.setMapping!( *self.getMapping! )
    new.frames      = self.frames
    new.frameTime   = self.frameTime
    return new
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
    @units = units

    # merge units and markers into a hash
    hash = Hash[ *markers.zip( units ).flatten ]

    # FIXME - below here
    hash.each_pair do |marker, unit|
      # take all markers and make sure they are downcased
      @markers[ marker.to_s.downcase ] = unit.to_s.downcase

      # generate a variable for each marker with a empty array
      self.instance_variable_set( "@#{marker.to_s.downcase}", Array.new )   # e.g. XTRAN/INCHES becomes @xtran => Array.new

      # learn getter and setter
      # TODO: doesn't ruby have a better way for this? inside functions?
      learn( "#{marker.to_s.downcase}=(val)", "@#{marker.to_s.downcase} = val" )      # Setter
      learn( "#{marker.to_s.downcase}", "@#{marker.to_s.downcase}" )                  # Getter

      #learn( "#{marker.to_s.downcase} val = nil", "( val.nil? ) ? ( return @#{marker.to_s.downcase} ) : ( @#{marker.to_s.downcase} << val )"  )
    end
  end

  def getMapping!
    return [@order, @units]
  end


  # = GetHeader returns the content of a segment header
  # @returns Returns an array with the header lines, each slot is a new line
  def getHeader
    header = []

    delimiter = " "
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

      ( i == ( frames.to_i - 1 ) ) ? ( printf( @format.join(" ").to_s + "\n", *getData( i ) ) ) : ( printf( @format.join(" ").to_s + "\n", *getData( i ) ) )
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

  p s.xtran
  #s.xtran( [] )
  #p "---"
  #p s.xtran



end


# vim=ts:2

