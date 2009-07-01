#! /usr/bin/ruby -w
#

# == Load libaries
require 'thread'                                                                  # load thread libary

# == Load custom libaries
#require 'Link'                                                                 # We store our links/stream info here - "custom data structure"
#require 'Fetch'                                                                # We use this interface to fetch our http objects
#require 'Extensions'

%w[Link Fetch Extensions].map( &method(:require) )

# Handles the interaction of $driver with the Music interface
class JBData
    def initialize
        @links = getLinks!                                                      # extract the pls links and store Link.new's in array
        ok = 0
        @links.each { |link| ok += 1 if( link.ok? ) }
        puts "Iteration complete... #{ok}/#{@links.length} are ok"
        #cnt = 0
        #while( broken?(@links) != 0) do
        #    @links = repairLinks!( @links )
        #    puts "Iteration #{cnt} | broken?(@links) == #{broken?(@links).to_s}"
        #    cnt += 1
        #end
    end

    def broken? links
        broken = 0
        links.each do |link|
            broken += 1 unless link.ok?
        end
        return broken
    end

    # Extracts the pls links from the given website
    # works for the Winamp Radio site
    # waits for the links until they finished extracting the pls urls
    def getLinks! baseURL = @@config.data['WinampStreamURL'], hpricotXPathExpr = @@config.data['WinampStreamHpricotXPath'], maxThreads = 3
        links     = Array.new                                                                                               # we store our Link.new's here
        content   = Fetch::get( baseURL )

        # Populate Links Array
        content.search(hpricotXPathExpr).each do |a|                                                       # extract all pls file links
            links << Link.new( a.attributes['title'], a.attributes['href'] ) if( a.attributes['href'] =~ %r{\.pls}i )
        end

        groups = links % maxThreads                                                                             # chunkenize the array to maxThread bits
        #groups.each_with_index { |group, index| printf("%2s. Group has %2s links\n",index, group.length) }
        #exit
        groups.each_with_index do |links, index|
            printf("%2s. Group with %2s links.\n", index, links.length)

            # Process .pls URL to get Stream URLs *threaded*
            links.each_with_index { |link, index| instance_variable_set( "@link#{index}", Thread.new { link.getPLSContent! } ) }
            0.upto( links.length-1 ) { |index| instance_variable_get("@link#{index}").join }
            ok = 0
            links.each { |link| ok += 1 if( link.ok? ) }
            puts "    o #{ok}/#{links.length} are ok"
            if( ok == 0 )
                puts "We seem to get blocked... sleeping for 60 seconds"
                sleep 60
            end
        end

        return groups.flatten
    end

    def repairLinks! links, timeout = 20
        threads = Array.new                                                                                     # store names of threads to wait for here

        links.each_with_index do |link, index|
            unless( link.ok? )
                instance_variable_set( "@link#{index}", Thread.new { link.getPLSContent!(timeout) } )
                threads << "@link#{index}"
            end
        end

        unless( threads.empty? )
            threads.each { |thread| instance_variable_get( thread ).join }
        end

        return links
    end

    def to_s
        @links.each do |link|
            puts link.to_s
        end
    end
end


# Whitebox testing on Wed Jul 11 04:32:34 JST 2007
testing = true
aop = false

if( testing )
    require 'JBConfig.rb'
   
    if( aop )
        require 'rubygems'
        require 'aspectr'
        include AspectR
        require 'AspectRLogger.rb'

        Logger.new.wrap(Link, :log_enter, :log_exit, /getPLSContent/)
    end

    @@config  = JBConfig.new                                                  # Load configuration
    data      = JBData.new
    data.to_s
end

