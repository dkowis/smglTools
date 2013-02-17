#!/usr/bin/env ruby

require 'open3'

input_file = ARGV[0]


File.readlines(input_file).each do |spell|
    spell = spell.strip
    urls = `gaze source_urls #{spell}`.split("\n")
    urls.each do |url|
        if url.include? "sourceforge"
            stdout, stderr, status = Open3.capture3("wget --tries=1 #{url} -O /dev/null")
            if status.success?
                puts "SUCCESS #{spell} - #{url}"
            else
                puts "   FAIL #{spell} - #{url}"
            end
        end
    end

end