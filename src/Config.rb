#!/usr/bin/ruby -w
#
#

# == Load libaries
require 'date'
require 'yaml'
require 'Extensions'
require 'ostruct'

# == Global/Instance Variables




# Loads / Stores given config 
class Config
    def initialize filepath = "./configuration/", filename = "Config.yml"
        @file = filepath + filename                                                 # Fully qualified filename
        
        if( File.exists?( @file ) )
            @config = load!
        else                                                                        # we need to create template
            @config = {
                "program" =>    {   "name" => "MotionX",
                                    "version" => "v0.1"
                                }

            }

            store!
        end

        @data = OpenStruct.new( @config ).remap!
    end

    # == Stores the given configuration to YAML File
    def store!
        File.open( @file, "w") { |file| YAML.dump( @config, file ) }
    end

    # BROKEN - Rewrite !
    def add filename
        return if( filename.nil? )
        dateTime = DateTime.now.to_s
        @config.files ||= Array.new
        @config.files.pop if @config.files.length > 5
        @config.files << [ dateTime, filename ]
        store!
    end

    # == Loads and replaces the configuration from File
    def load!
        File.open( @file, "r" ) { |file| YAML.load( file ) }                 # return proc which is in this case a hash
    end

    # lets make a easy mapping
    # Instead of calling outside: e.g. @@config.data["visualization"]["grid"]["size"] we want, @@config.visualization.grid.size
    # Only ok if the key is explict ! e.g. {:foo => 1, 'foo' => 2}.foo  <--- ?
    #    def method_missing( *args )
    #        if @config.keys.include?( args.first )
    #            return self[ args.first ]
    #        else
    #            p args
    #            exit
    #            super
    #        end
    #    end

    attr_accessor :config, :data
    alias :data :config
end


# Make a hash[key1][key2][key3] into hash.key1.key2.key3
# class OpenStruct
#    def remap!
#        ( self.methods - OpenStruct.new.methods ).each do |method|
#            puts "Method: #{method}"
#            if method =~ %r{=}
#                # FIXME this is a setter function
#            else
#                puts "Its not a setter function"
#                object = eval( "self.#{method.to_s}" )
#
#                if object.class.to_s.match( "Hash" )
#                    puts "Its a hash"
#                    learn( "self.#{method}", OpenStruct.new( object ) )
#                else
#                    # not a hash
#                end
#            end
#        end
#    end
#
#private
#
#    def remap hash
#        
#    end
#
#end


# Just for Blackbox-testing, when run directly
#if __FILE__ == $0
#    config = Config.new( "./configuration/", "RecentlyOpened.yml" )
#    config.add "/foo/baz/bar.foo"
#end

