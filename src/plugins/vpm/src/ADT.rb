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
    @body       = Body.new

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

    data = []
    data = File.open( file, "r" ).readlines.collect { |a| a.chomp! }

    ###
    # Split content into segments
    #####

    # How many segments do we have and what is their name? Also create for each segment a segment object.
    data.each do |l|
      if l.to_s =~ %r{Segment:}i
        s = l.split(":").last.strip.to_s.downcase
        s.gsub!( "-", "_" )

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


  # = crop function takes a range and crops the motions contained in self
  # Crop function takes a range and crops the motions contained in self accordingly and writes them to internal state.
  def crop from = 0, to = @pt24.frames.to_i, segments = @segments # {{{


    segments.each do |segment|
      eval( "@#{segment.to_s}.crop!( #{from}, #{to} )" )
    end

  end # of def crop from = 0, to = @pt24.frames.to_i, segments = @segments # }}}


  # = combine function takes a range and combines all the motions into one average pose
  def combine segments = @segments # {{{

    segments.each do |segment|
      eval( "@#{segment.to_s}.combine!" )
    end
  end # of def combine segments = @segments # }}}


  # = processSegment takes a segment string and returns a segment object, but also sets the object.
  # @param string String is one segment ans one string incl. newlines etc.
  # @returns Returns a Segment object generated from the given string e.g. "Segment: RWFT...." -> @rwft = Segment.new...
  # @warning First line in the string needs to be a segment definition. The Segment section needs to
  #          validate specification otherwise this function will fail. Run vpmcheck first.
  def processSegment string # {{{
    data = string.split("\n")

    # Very bad hack - fix this properly. why does the crop function not work as expected?
    #from = 14159
    #to   = 15002

    # Get meta information
    segment     = data.shift.to_s.split(":").last.strip
    frames     = data.shift.to_s.split(":").last.strip
    # Very bad hack - fix this properly. why does the crop function not work as expected?
    #frames      = (to - from)

    frameTime   = data.shift.to_s.split(":").last.strip

    # Extract marker and unit names
    m           = data.shift.to_s.split(" ").collect { |i| i.downcase }
    u           = data.shift.to_s.split(" ").collect { |i| i.downcase }

    # Set marker mappings and other variables as instance variables
    eval( "@#{segment.downcase}" ).setMapping!( m, u )
    eval( "@#{segment.downcase}" ).frames    = frames
    eval( "@#{segment.downcase}" ).frameTime = frameTime

    # Only data (one segment!) left
    data.each_with_index do |line, outer_index|
      # Very bad hack - fix this properly. why does the crop function not work as expected?
      # next if( (outer_index < from) or (outer_index > to) )

      d = line.split(" ")
      m.each_with_index do |marker, index|
        begin
          eval( "@#{segment.downcase}.#{marker.to_s} << #{d[index]}" ) 
        rescue
          puts "Error with #{segment.downcase.to_s}.#{marker.to_s} << #{d.join(", ")} for d[#{index.to_s}]" 
        end
      end
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


  #= setNewSegment! sets a new given segment with the same frame, frametime, and markers + order as existing ones
  # @param name A string representing the name of the segment, e.g. "rwft". It will be used as instance variable e.g. "@rwft"
  # @param description A string describing the point's meaning on the body. E.g. Rear Waist Forward Top half..." etc.
  # @returns A segment object with the name and description. Also sets a instance_variable with the same name and data
  def setNewSegment! name, description, value # {{{

    # Generate a variable for each segment
    self.instance_variable_set( "@#{name.to_s}", value )     # same idea as in Segment.rb 

    # TODO: Add meta information for segments

    learn( "#{name.to_s}", "return @#{name.to_s}" ) # Getter function

    value
  end # }}}


  # = computeExtraPoints does exactly as the name suggests. See S. Kudoh Thesis (p. 109) for more info on this.
  def computeExtraPoints! # {{{

    %w[pt24 pt25 pt26 pt27 pt28 pt29 pt30 pt31].each do |var| 
      getNewSegment!( var.to_s, "" )
      @segments << var.to_s
    end 

    # Standard Points from S. Kudoh Thesis
    @pt24 = ( @lfhd + @lbhd + @rfhd + @rbhd ) / 4
    @pt25 = ( @lsho + @rsho )                 / 2
    @pt26 = ( @lwra + @lwrb )                 / 2
    @pt27 = ( @rwra + @rwrb )                 / 2

    begin
      @pt28 = ( @lfwt + @lbwt )                 / 2
    rescue
      puts "Couldn't calculate pt28 = ( lfwt + lbwt )"
    end

    begin
      @pt29 = ( @rfwt + @rbwt )                 / 2
    rescue
      puts "Couldn't calculate pt29 = ( rfwt + rbwt )"
    end

    @pt30 = ( @pt28 + @pt29 )                 / 2
    @pt31 = ( @pt25 + ( @pt30 * 2 ) )         / 3     # FIXME: Depends on normalization, see Motion Viewer code
  end # }}}


  # = check parses a VPM file and looks for errors. In case of error it returns false
  def valid? file = @file # {{{

  end # end of valid? }}}


#  # = write dumps a given VPM data into a file
#  # @param file Expects a string with a full URI as path/file combination
#  # FIXME: This method is b1rked because the Segment.rb to_s function uses printf instead of returning proper strings.
#  # @returns Boolean, true if write succeeded and false if not.
#  def write file = "/tmp/MotionX_Output.vpm" # {{{
#    @result = []
#
#    original_stdout = $stdout.clone
#    STDOUT.sync = true
#    $stdout.reopen( File.new( file, File::CREAT|File::APPEND|File::RDWR, 0644 ) )
#
#    # rendering of each segment is done in Segment.rb
#    @segments.each { |segmentName| @result << eval( "@#{segmentName.to_s}" ).to_s }
#
#    # File.open( file, File::CREAT|File::TRUNC|File::RDWR, 0644) { |f| f.write( @result.join("\n") ) }
#
#    $stdout.flush
#    $stdout.reopen( original_stdout )
#  end # end of write }}}


  # = write dumps a given VPM data into a file
  # @param file Expects a string with a full URI as path/file combination
  # FIXME: This method is b1rked because the Segment.rb to_s function uses printf instead of returning proper strings.
  # @returns Boolean, true if write succeeded and false if not.
  def write file = "/tmp/MotionX_Output.vpm" # {{{
    @result = []

    # rendering of each segment is done in Segment.rb
    @segments.each { |segmentName| @result << eval( "@#{segmentName.to_s}" ).to_s }

    File.open( file, File::CREAT|File::TRUNC|File::RDWR, 0644) { |f| f.write( @result.join("") ) }
  end # end of write }}}


  # = writeCSV takes output from e.g. getTurningPoints form and dumps it into $file
  # @param file Needs a URI (string) which points to the location where you want to store your data in csv format.
  # @param data Needs data which is in the form which comes from the getTurningPoints function.
  # @returns Boolean, if write was successful or not.
  # @warning Truncates the file if existent.
  def writeCSV file = nil, data = getTurningPoints # {{{
    raise ArgumentError, "Need a valid filename/target" if file.nil?

    File.open( file, File::WRONLY|File::TRUNC|File::CREAT, 0666 ) do |f|
      f.write( "index, x, y\n" )
      f.write( data.join( "\n" ) )
    end
  end # end of writeCSV }}}


  # = local_coordinate_system takes a center marker and calculates the new position of all markers
  # to that given marker, thus making all coorinates local to this marker.
  def local_coordinate_system center = nil, segments = @segments # {{{

    center_segment = instance_variable_get( "@"+center.to_s )
    raise ArgumentError, "center_segment variable must be of type segment" unless( center_segment.is_a?( Segment ) )

    segments.each do |segment|

      old = instance_variable_get( "@"+segment.to_s )
      eval( "@#{segment.to_s}_backup = old" )         # make a backup for later undo

      raise ArgumentError, "old variable must be of type segment" unless( old.is_a?( Segment ) )

      new = old - center_segment
      eval( "@#{segment.to_s} = new" )
    end

  end # of def local_coordinate_system center = nil # }}}


  def local_coordinate_system_undo segments = @segments
    segments.each do |segment|
      old = instance_variable_get( "@#{segment.to_s}_backup" )
      eval( "@#{segment.to_s} = old" )
    end
  end


  attr_accessor :segments, :file, :body
end # end of ADT class }}}


# = Direct invocation, for manual testing besides rspec
if __FILE__ == $0

  raise ArgumentError, "Needs a filename as input" if( ARGV.empty? )
  filename        = ARGV.first.to_s

  puts "Using #{filename.to_s}"
  adt             = ADT.new( filename )

  current_frames  = adt.instance_variable_get( "@#{adt.segments.first.to_s}" ).frames
  puts "Currently the file has #{current_frames.to_s} frames"

  puts "Cropping to 2-49"
  adt.crop( 2, 49 )

  adt.local_coordinate_system( "pt30" )


  #adt.combine
  # printout  = adt.instance_variable_get( "@#{adt.segments.first.to_s}" ).to_s
  # puts printout
  adt.write

#  points  = adt.getTurningPoints( "p27", "relb", "p26", "lelb", "p30")
#  ret     = adt.writeCSV( "/tmp/results.csv", points )

#  adt     = ADT.new( "../sample/Jongara.vpm" )
#  points  = adt.getTurningPoints( "p27", "relb", "p26", "lelb", "p30", 1400, 1500 )
#  values = []
#  points.each do |string|
#    index, x, y = *(string.to_s.gsub(" ","").split(","))
#    index   = index.to_i
#    x       = x.to_f
#    y       = y.to_f
#
#    values << [index,x,y]
#  end
#
#  results = []
#  i = 0
#  threshhold = 1
#
#  # If the frame i we are in is a twisting point we set a 1 if not 0
#  values.each do |array|
#    index, x, y = array.shift, array.shift, array.shift
#    index   = index.to_i
#    x       = x.to_f
#    y       = y.to_f
#
#    if( values.length >= (i+2) )    # only get values in the range of our array
#      thisX = x
#      thisY = y
#
#      x2 = ((values[ i+1 ].to_s.gsub(" ","").split(","))[1]).to_f
#      y2 = ((values[ i+1 ].to_s.gsub(" ","").split(","))[2]).to_f
#
#      x3 = ((values[ i+2 ].to_s.gsub(" ","").split(","))[1]).to_f
#      y3 = ((values[ i+2 ].to_s.gsub(" ","").split(","))[2]).to_f
#
#
#      finalX = (x+x2+x3)/3.0
#      finalY = (y+y2+y3)/3.0
#
#      if( (finalX or finalY) >= threshhold )
#        results << 1
#      else
#        results << 0
#      end
#    else
#      # push a 0
#      results << 0
#    end
#
#    i += 1
#  end
#

  #
  # 1.) Ruby19
  # 2.) RubyProf
  # 3.) Tuning
  #

#  results.each_with_index { |r, i| puts "#{i.to_s}  -> #{r.to_s}" }

  #ret     = adt.writeCSV( "/tmp/results.csv", points )


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
