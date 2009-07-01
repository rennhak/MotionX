#!/usr/bin/ruby -w

require 'rubygems'
require 'aspectr'
include AspectR

class Logger < Aspect
    
    def tick; "#{Time.now}"; end
    
    def log_enter(method, exitstatus, *args)
        $stderr.puts "#{tick} #{self.class}##{method}: args = #{args.inspect}"
    end 
    def log_exit(method, exitstatus, *args)
        $stderr.print "#{tick} #{self.class}##{method}: exited "
        if exitstatus.kind_of?(Array)
            $stderr.puts "normally returning #{exitstatus[0].inspect}"
        elsif exitstatus == true
            $stderr.puts "with exception '#{$!}'"
        else
            $stderr.puts "normally"
        end
    end
end


