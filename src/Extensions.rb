#!/usr/bin/ruby -w

####
#
# File: Extensions.rb
#
# (c) 2009, Bjoern Rennhak, The University of Tokyo
#
########


# FIXME: This is namespace pollution, avoid by segmenting it in a separate namespace.


# Silly hack to know the caller position of each object
class Object
    def method_name
        return self.class.name+"::"+$1.to_s if  /`(.*)'/.match(caller.first)
        nil
    end
end


# super nifty way of chunking an Array to n parts
# found http://drnicwilliams.com/2007/03/22/meta-magic-in-ruby-presentation/
# direct original source at http://redhanded.hobix.com/bits/matchingIntoMultipleAssignment.html
class Array
    def %(len)
        inject([]) do |array, x|
            array << [] if [*array.last].nitems % len == 0
            array.last << x
            array
        end
    end
end

# now e.g. this is possible
#test = false
#if(test)
#    array = Array.new
#    0.upto(10) {|n| array << "foo"+n.to_s }
#    p array%3
#end


#[15:40][br@mercury:programming/ruby/ruby_jukebox]% ./Extensions.rb 
#["foo0", "foo1", "foo2", "foo3", "foo4", "foo5", "foo6", "foo7", "foo8", "foo9", "foo10"]
#[15:40][br@mercury:programming/ruby/ruby_jukebox]% ./Extensions.rb
#[["foo0", "foo1", "foo2"], ["foo3", "foo4", "foo5"], ["foo6", "foo7", "foo8"], ["foo9", "foo10"]]

