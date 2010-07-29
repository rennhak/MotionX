#! /usr/bin/ruby
#

# == Load libaries
require 'rubygems'
require 'optparse'                                                      # Handles the commandline options/parsing
require 'date'                                                          # For the --version

# == Load custom libaries
require 'MotionXConfig'
require 'Extensions'

# Require Logging Part (log4r)
require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'             # we use various outputters, so require them, otherwise config chokes
#require 'log4r/outputter/emailoutputter'
include Log4r                                           # Change Namespace

# Pretty useful for boosting error robustness - "Monkey Patching" (tm) dr. nic
#require 'guessmethod'


# == Global/Instance Variables
@@version  = "$Id$"                                                     # SVN Revision string
@@author   = "Bjoern Rennhak"
@@options  = {}                                                         # Our Options hash carrying
@@config  = MotionXConfig.new                                                  # Load configuration


######
#
# Configuration of the Log4r logger
#

config = YamlConfigurator
config['HOME'] = '.'                                        # Define custom Parameters for the YAML File
config.load_yaml_file('../configuration/Logger.yaml')          # Load logging config
#Outputter['email'].level = OFF                              # Turn off E-Mail logging

#
###########

# == MotionX is the Main Class handling everything of this project.
class MotionX
    def initialize
        @log = Logger[self.class.name.to_s]                                                    # Logger instance for the Top20Downloader Class
        @log.debug { "Created a #{self.class.name} Class" }                                    # Use {} to skip dynamic evals during loglevel change

    end



end




# == OptionParser handling
optionParser = OptionParser.new do |opts|
    opts.banner = "Usage: #{$PROGRAM_NAME} [options]"

    opts.on("-t", "--textmode", "Force ASCII Textmode (limited functionality)") do |t|
        @@options[:textmode] = t
    end

    opts.on("-v", "--verbose", "Run verbosely") do |v|
        @@options[:verbose] = v
    end

    opts.on("--very-verbose", "Run very verbosely") do |vv|
        @@options[:veryverbose] = vv
    end

    opts.on("-u", "--usecache", "Use existing cached data (if exists)") do |u|
        @@options[:usecache] = u
    end

    opts.on_tail("-h", "--help", "This help screen") do |h|
        @@options[:help] = h
        puts opts
        exit
    end

    opts.on_tail("--version", "Version of #{File.basename($PROGRAM_NAME)}") do |v|
    @@options[:version] = v
        puts "#{File.basename($PROGRAM_NAME)} Version #{@@version}"
        print "Copyright (c) "
        ( DateTime.now.year == 2009 ) ? ( print DateTime.now.year ) : ( print "2007-#{DateTime.now.year.to_s}" )
        puts " #{@@author}"
        exit
    end
end

# == OptionParser execution
begin
    optionParser.parse!(ARGV)                                           # Parse given ARGV's
    jukebox = MotionX.new                                               # Fire up MotionX
rescue => exc                                                           # in case of trouble bail out
    STDERR.puts "E: #{exc.message}"
    STDERR.puts optionParser.to_s
    exit 1
end


# vim:ts=2:tw=100:wm=100
# EOF
