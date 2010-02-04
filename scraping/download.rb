require 'yaml'
require 'find'
require 'fileutils'


# load up grimoire data... wonder how well this will behave
#TODO: should have it passed in
historyFile="stable-dl.yaml"
codex = Hash.new()
if File.exist?(historyFile) then
	puts "Loading up the history"
	codex = YAML.load_file(historyFile)
end

codex.each do |grimoire,gvalue|
	puts "Grimoire: #{grimoire}"
	gvalue.each do |section,svalue|
		puts "\tSection: #{section}"
		if svalue then
			svalue.each do |spell,sourceFile|
				puts "\t\tSpell: #{spell}"
				if sourceFile then
					sourceFile.each do |file,more|
						puts "\t\t\tSource File:  #{file}"
						puts "\t\t\tVerification: #{more['verification']}"
					end
				else
					puts "\t\t\tNo source files"
				end
			end
		else
			puts "\t\tNo additional data"
		end
	end
end

