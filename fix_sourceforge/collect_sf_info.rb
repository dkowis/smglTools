#!/usr/bin/env ruby

# used to find all the source file names that want SF.net urls
SF_URL=/.*\$\{?SOURCEFORGE_URL\}.*/
SOURCE = /.*SOURCE=(.*)/
SPELL = /.*SPELL=(.*)/
VERSION = /.*VERSION=(.*)/

Dir.glob("*/*/DETAILS").each do |file|
    begin
        text = File.read(file)
        if text.match SF_URL
            version = VERSION.match(text)[1]
            source = SOURCE.match(text)[1]
            spell = SPELL.match(text)[1]

            real_source = source.gsub(/\$\{?SPELL\}?/, spell).gsub(/\$\{?VERSION\}?/, version)
            puts "#{spell}|#{real_source}"
        end
    rescue Exception => e
        #MEH!
    end
end