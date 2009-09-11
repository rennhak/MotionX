#!/usr/bin/ruby
#
#

#require 'Qt4'
require 'yaml'
require 'ostruct'

##
# FIXME: This is namespace pollution, avoid by segmenting it in a separate namespace.
####


# Override some default YAML Behavior and create OpenStructs instead of Hashes when called
# http://rubyquiz.com/quiz81.html
class << YAML::DefaultResolver
    alias_method :_node_import, :node_import
    def node_import(node)
        o = _node_import(node)
        o.is_a?(Hash) ? OpenStruct.new(o) : o
    end
end


# Create new features for the OStruct class
# http://snippets.dzone.com/tag/hash
# This class provides a few new capabilities in addition to what is provided by
# the OpenStruct class.  The method _to_hash will return a hash representation of
# the struct, including nested structs.  The method _table will return a hash
# representation, but will not resolve any nested structs.  The method
# _manual_set takes a hash and adds it to the struct. This is similar to
# OpenStruct's ability to take a hash as an initial argument to create a struct,
# this method allows the struct to be modifed post instantiation.  The method
# names start with an _ (underscore) to avoid any conflicts between these methods
# and struct assignments.  Implementation note: I created a new class rather than
# extending the existing OpenStruct class due to my personal preference of not
# changing the behavior for standard library classes. However, one could just as
# easily extend the OpenStruct class with these behaviors as well.
class OpenStruct
  def _to_hash
    h = @table
    #handles nested structures
    h.each do |k,v|
      if v.class == OpenStruct
        h[k] = v._to_hash
      end
    end
    return h
  end
  
  def _table
    @table   #table is the hash structure used in OpenStruct
  end
  
  def _manual_set(hash)
    if hash && (hash.class == Hash)
      for k,v in hash
        @table[k.to_sym] = v
        new_ostruct_member(k)
      end
    end
  end
end


# == Ninjapatching for Ruby
class Array
    def delete_unless &block
        delete_if{ |element| not block.call( element ) }
    end

    # super nifty way of chunking an Array to n parts
    # found http://drnicwilliams.com/2007/03/22/meta-magic-in-ruby-presentation/
    # direct original source at http://redhanded.hobix.com/bits/matchingIntoMultipleAssignment.html
    def %(len)
        inject([]) do |array, x|
            array << [] if [*array.last].nitems % len == 0
            array.last << x
            array
        end
    end

    # now e.g. this is possible
    #test = false
    #if(test)
    #    array = Array.new
    #    0.upto(10) {|n| array << "foo"+n.to_s }
    #    p array%3
    #end

    # % ./Extensions.rb 
    # ["foo0", "foo1", "foo2", "foo3", "foo4", "foo5", "foo6", "foo7", "foo8", "foo9", "foo10"]
    # % ./Extensions.rb
    #[ ["foo0", "foo1", "foo2"], ["foo3", "foo4", "foo5"], ["foo6", "foo7", "foo8"], ["foo9", "foo10"]]


    def sum
      inject( nil ) { |sum,x| sum ? sum+x : x }
    end

    def mean
      sum / size
    end
end

class String
    def capitalizeOnlyFirstLetter
        self.replace( self.gsub(/^[a-z]|\s+[a-z]/) { |a| a.upcase } )
    end
end


class Hash

  # http://snippets.dzone.com/tag/hash
  # Collapse a multi-dimensional hash into a single-dimensional hash
  def flatten_keys(newhash={}, keys=nil)
    @@keys ||= []

    self.each do |k, v|
      k = k.to_s
      keys2 = keys ? keys+"."+k : k
      @@keys << keys2

      if v.is_a?(Hash)
        v.flatten_keys( newhash, keys2 )
      else
        newhash[keys2] = v
      end
    end
    newhash
  end

  # Ugly. FIXME
  def getKeysOfNestedHash
    @@keys
  end

  def recursive_merge(h)
    self.merge!(h) {|key, _old, _new| if _old.class == Hash then _old.recursive_merge(_new) else _new end  }
  end

  def delete_unless &block
    delete_if{ |key, value| not block.call( key, value ) }
  end

  # This is dangerous, see require 'ostruct'
  # # Make access like hashObject.key1.key2.key3 possible
  # def method_missing(*args)
  #     return self[args[0]] if self.keys.include?(args[0])
  #     super
  # end

end


class Object
    # == Dynamical method creation at run-time
    def learn method, code
        eval <<-EOS
            class << self
                def #{method}; #{code}; end
            end
        EOS
    end

    # Silly hack to know the caller position of each object
    def method_name
        return self.class.name+"::"+$1.to_s if  /`(.*)'/.match(caller.first)
        nil
    end
end


#http://www.nach-vorne.de/2007/4/24/attr_accessor-on-steroids
class Module
  #def attr_accessor_with_default_setter( *syms, &block )
  def attr_default( *syms, &block )
    raise 'Default value in block required' unless block
    syms.each do | sym |
      module_eval do
        attr_writer( sym )
        define_method( sym ) do | |
          class << self; self; end.class_eval do
            attr_reader( sym )
          end
          if instance_variables.include? "@#{sym}"
            instance_variable_get( "@#{sym}" )
          else
            instance_variable_set( "@#{sym}", block.call )
          end
        end
      end
    end
    nil
  end
end



#  # Ninjapatching for QtRuby
#  class CustomFrame < Qt::Frame
#     def initialize( parent, owner, name = nil )
#        #super( owner, name )
#        super( owner )
#          self.objectName = name unless name.nil?
#          self.frameShape = Qt::Frame::StyledPanel
#          self.frameShadow = Qt::Frame::Raised
#  
#        @parent = parent
#        #setFrameStyle(Qt::Frame::WinPanel | Qt::Frame::Sunken)
#     end
#  
#     # redraw image on these events
#     def paintEvent(*e)
#        @parent.refreshImage
#     end
#  
#     def resizeEvent(*e)
#        @parent.drawImage
#     end
#  
#     def contextMenuEvent(*e)
#        popup = Qt::PopupMenu.new()
#        popup.insertItem("Copy Chart to Clipboard",@parent,SLOT("copyChartToClipboard()"))
#        popup.popup(e.first.globalPos)
#     end
#  end
#  

# # Create a more flexible CallStack for tricks in RhythmEditor::messageBox etc.
# # http://eigenclass.org/hiki.rb?ruby+backtrace+data#f01
# $rec = CallStackRecorder.new
# $rec.install_hook
# 
# class CallStack
#   def initialize(stack = []); @stack = stack end
#   def <<(x); @stack << x end
#   def pop; @stack.pop end
#   def last(n = 1); @stack[-[n,@stack.size].min..-1] end # bomb for n <= 0?
#   def tos; @stack.last end
#   def to_a; @stack end
# end
# 
# CALLSITES = Hash.new{|h,k| h[k] = Hash.new{|h2,k2| h2[k2] = 0 } }
# 
# class CallStackRecorder
#   CallSite = Struct.new(:klass, :mid, :file, :line)
# 
#   def initialize
#     @callstack_tbl = Hash.new{|h,k| h[k] = CallStack.new }
#   end
# 
#   def install_hook 
#     prefill_callstack_tbl
#     ignore = false
#     set_trace_func lambda{|event, file, line, mid, binding, klass|
#       if [klass, mid] == [CallStackRecorder, :callstack]
#         case event
#         when 'return': ignore = false; next
#         when 'call': ignore = true
#         end
#       end
#       next if ignore
#       case event
#       when 'c-call', 'c-return': file, line = nil, 0
#       end
#       case event
#       when 'call', 'c-call'
#         # this was different in the C implementation, where klass was always
#         # the real one (it could even be an ICLASS aka. proxy class)
#         receiver = eval("self", binding)
#         klass = class << klass; self end unless klass === receiver
#         cstack = callstack(1)
#         CALLSITES[[klass, mid]][cstack] += 1
#         @callstack_tbl[Thread.current] << CallSite.new(klass, mid, file, line)
#       when 'return', 'c-return'
#         @callstack_tbl[Thread.current].pop
#       else
#         last_site = @callstack_tbl[Thread.current].tos
#         if last_site && file && line && last_site.mid == mid && last_site.file == file &&
#           last_site.klass == klass
#           last_site.line = line
#         end
#       end
#     }
#   end
# 
#   def remove_hook
#     set_trace_func(nil)
#   end
# 
#   def callstack(depth)
#     r = @callstack_tbl[Thread.current].last(depth)
#     r.reverse
#   end
# 
#   private
# 
#   # works only for the thread that called #install_hook; part of the backtrace
#   # is lost for the rest
#   def prefill_callstack_tbl
#     @callstack_tbl[Thread.current] = CallStack.new format_backtrace_array(caller(2))
#   end
# 
#   def format_backtrace_array(backtrace)
#     backtrace.map do |line|
#       md = /^([^:]*)(?::(\d+)(?::in `(.*)'))?/.match(line)
#       raise "Bad backtrace format" unless md
#       CallSite.new(nil, md[3] ? md[3].to_sym : nil, md[1], (md[2] || '').to_i)
#     end
#   end
# end
 
