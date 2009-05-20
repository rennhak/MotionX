#!/usr/bin/ruby -w
#

# (c) 2009, Bjoern Rennhak, The University of Tokyo
# This provides the Media YAML functionality.


####
#
#
# Generic YAML Format for 
#     o Motion Capture Data in format X
#     o Sound Data in format Y
#     o Sensor Placement Graphic in format Z
#
#     -> Data Structure :
#
# Remark: Empty values get a "nil" value; Frame time in one file may NOT vary, this is used for an integrety check.
#
# ---
# metadata:
#   motion:
#     name: <DANCE NAME>                                                      # e.g. Aizu Ban Daisan ; BUT it could also be a simple motion ; e.g. "Walking two meters casually"
#     type: <TYPE OF DANCE>                                                   # e.g. Japanese Folk Dance
#     by: <PERSON WHO DANCED NAME>                                            # e.g. Max Mueller
#     gender: <GENDER>                                                        # Either "Male" or "Female"
#     capturedTime: <DATETIME>                                                # when the original .VPM was captured
#     capturedBy: [ <NAMES AND GROUPS WHO CAPTURED THIS> ]                    # Array; e.g. [ "Warabi-za Co. Ltd., Japan", "Computer Vision Laboratory, Tokyo University, Japan",.. ]
#     clothes: <COMMENT ABOUT THE CLOTHES USED>                               # e.g. traditional japanese xyz clothing
#     utils: <COMMENT ABOUT THE UTILITIES USED>                               # e.g. Traditional Fan XY
#     contact: [ <NAME AND $ADDRESS> ]                                        # e.g. [ "Max Mueller", "mueller@danceschool.co.jp", "Warabi-za Co. Ltd.", ... ]
#   capture:
#     device: <CAPTURE DEVICE>                                                # e.g. Vicon WS Motion Capture System
#     sensors: <NUMBER OF SENSORS USED>                                       # e.g. 33
#     area: [ <APPROXIMATE CAPTURE AREA> ]                                    # e.g. [ 4, 4, "meter" ]
#     placement: <EXPLANATION OF THE SENSOR PLACEMENT>                        # e.g. "One sensor was placed on the... . The next one called XYZ was placed on... "
#   sound:
#   format:
#     file:
#       before: <FILE FORMAT BEFORE>                                          # e.g. VPM + VERSION
#       now: <FILE FORMAT NOW>                                                # e.g. YAML + VERSION
#     data:
#       segments: [ <AN ORDERED LIST OF ALL SEGMENTS - 1...X>  ]              # Array; e.g. RFWT,...a
#       category:                                                             # Array of groups (this is useful to determine the order of the sensors, Nr. 1 .. x
#         [ [ <GROUP>, <UNIT> ], .... ]                                       # e.g. [ [ "XTRAN", "INCHES" ], ... ] etc.
#       frames:
#         perSecond: <FRAMES PER ONE SECOND>                                  # framespersecond = 1 / frametime ; e.g. 1 / 0.008333 = 120 frames/s
#         time: <TIME OF RAW CAPTURE PER FRAME>                               # Raw frametime which was used during capture; e.g. 0.008333
#         amount: <TOTAL AMOUNT OF FRAMES>                                    # e.g. Frames -> 2400
#   maintenance:
#     contact:   [ <NAME AND $ADDRESS> ]                                      # e.g. [ "Bjoern Rennhak", "br@cvl.iis.u-tokyo.ac.jp", "The University of Tokyo", ... ]
#     convertedtime: <DATETIME>                                               # when it was converted from .VPM -> .YAML
#     motionCaptureConverterVersion: <VERSION NR OF THIS SOFTWARE>            # e.g. 0.0.1a
#
#
# sensorPlacementGraphicData:
#   encoding: <ENCODING FORMAT>                                               # e.g. Base64
#   subEncoding: <SUBENCODING OF FILE>                                        # e.g. "JPG"
#   data: <DATA HERE>                                                         # ..
#
#
# sound:
#   type: <TYPE OF SOUND>                                                     # e.g. "Music" or "Voice" or "Noise...
#   subType: [ <SUBTYPE OF SOUND> ]                                           # e.g. [ "$CATEGORY", "Japanese Folk Dance", "..." ]
#   encoding: <ENCODING>                                                      # e.g. Base64
#   subEncoding: <SUBENCODING>                                                # e.g. MP3
#   title: <NAME OF THE MUSIC>                                                # e.g. Aizu Ban Daisan ...
#   bpm: <VALUE OF BEATS PER MINUTE>                                          # e.g. 85
#   speed: <VALUE OF SPEED ; RELATIVE>                                        # e.g. 1.0
#   data: <DATA HERE>                                                         # ...
#
#
# motion:
#     <SENSOR>:                                                               # e.g. RFWT:
#       <CATEGORY>: <VALUE>                                                   # e.g XTRAN: -4.864795
#       <CATEGORY>: <VALUE>                                                   # ...
#       ...
#     <SEGMENT>:
#       ...
#
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



  # = yaml! turns the VPM data into YAML format
  def yaml!

  end

end












# Module Testing on direct invocation
if __FILE__ == $0

  vpm = VPM.new( "../data", "Aizu_Female.vpm" )
  vpm.getSegments
end
