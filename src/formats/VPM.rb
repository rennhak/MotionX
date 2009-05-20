#!/usr/bin/ruby -w
#

# (c) 2009, Bjoern Rennhak, The University of Tokyo
# This file reads VPM


#####
#
# VPM Format -> Data Structure now:
#
# Segment:        RFWT
# Frames: 2400
# Frame Time:     0.008333
# XTRAN   YTRAN   ZTRAN   XROT    YROT    ZROT    XSCALE  YSCALE  ZSCALE
# INCHES  INCHES  INCHES  DEGREES DEGREES DEGREES PERCENT PERCENT PERCENT
# -4.864795 32.797893 2.210924 180.000000 46.793425 180.000000 100.000000 100.000000 100.000000
# ....
# Segment:        .....
# ....
#
#############


# = This class is a VPM Data convenience function
class VPM
  
  # @param path     Expects a *valid* path without any "/" or "\" at the end.
  # @param filename Expects a *valid* VPM file without any "/" or "\" in it.
  def initialize path, filename
    @path, @filename  = path, filename
    @data             = File.open( "#{path}/#{filename}", "r" ).readlines               # Read all contents from file
    
  end

  # = GetSegments chunks off each segment of the vpm data into an array slot
  def getSegments data = @data
    

    # Do segmentation match for "Segment:"
    data.each do |line|
      

      puts line if line =~ %r{Segment:}i
    end

    results
  end

end












# Module Testing on direct invocation
if __FILE__ == $0

  vpm = VPM.new( "../data", "Aizu_Female.vpm" )
  vpm.getSegments
end
