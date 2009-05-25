#! /usr/bin/ruby -w
#

# == Load libaries
require 'yaml'

# == Global/Instance Variables

# Loads / Stores given config 
class MotionXConfig
    def initialize filepath = "../configuration/", filename = "Config.yml"
        @file = filepath + filename                                                 # Fully qualified filename
        
        if( File.exists?( @file ) )
            @config = load!
        else                                                                        # we need to create template
            @config = {
                #"WinampStreamURL" => "http://www.winamp.com/media/radio",            # we get our streams from here
                #"WinampStreamHpricotXPath" => "div[@class=box_body]//strong//a"     # we need this XPATH expr to extract the links to the .pls files
            }

            store!
        end
    end

    # == Stores the given configuration to YAML File
    def store!
        File.open( @file, "w") { |file| YAML.dump( @config, file ) }
    end

    # == Loads and replaces the configuration from File
    def load!
        File.open( @file, "r" ) { |file| YAML.load( file ) }                 # return proc which is in this case a hash
    end

    attr :config
    alias :data :config
end
