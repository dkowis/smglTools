#!/usr/bin/env ruby

require 'capybara'
require 'capybara/dsl'
require 'open3'

Capybara.default_driver = :selenium
Capybara.run_server = false
Capybara.app_host = "http://sourceforge.net"

class Working
    include Capybara::DSL

    def find_spell(spell)
        visit "/projects/#{spell}"
    end

    def has_download_link?
        page.has_xpath? "/html/body/div[3]/article/section/section/section[2]/a/span/b"
    end

    def extract_path
        find(:xpath, "/html/body/div[3]/article/section/section/section[2]/a/span/small")['title']
    end
end

#spells = File.readlines(ARGV[0])
spells = %w{gpac}

work = Working.new
spells.each do |spell|
    spell.strip!
    work.find_spell(spell)
    if work.has_download_link?
        path = work.extract_path
        puts "PATH is #{path}"
        url = "http://downloads.sourceforge.net/project/#{spell}#{path}"
        stdout, stderr, status = Open3.capture3("wget --tries=1 \"#{url}\" -O /tmp/#{spell}.tar.gz")
        if status.success?
            puts "SUCCESS|#{spell}|#{url}"
        else
            puts "FAIL|#{spell}|#{url}"
        end
    end
end

