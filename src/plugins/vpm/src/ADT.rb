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
  def initialize
    
  end


  # attr_accessor
  # attr_reader
  # attr_writer

end


# Direct invocation, for manual testing beside rspec
if __FILE__ == $1
  
end


# vim=ts:2

