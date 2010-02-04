require 'yaml'
require 'open-uri'
require 'pp'
require 'tempfile'
require 'progressbar'

def verify_spell(spell)
	puts "starting to verify this"
	temp = Tempfile.new("#{spell[0]}") #spell name
	# Pretty print the spell package, so I know the structure of what I created, heh
	#pp spell[1]
	spell[1].each do |file,data|
		puts "Spell file: #{file}"
		puts "Verification type: #{data['verification']}"
		begin
			data["sources"].each.each do |source|
				source.each do |sourcevar, url|
					puts "Verifying source for: #{sourcevar}"
					puts "--> #{url}"
					pbar = nil
					open(url,
						:content_length_proc => lambda {|t|
							if t && 0 < t
								pbar = ProgressBar.new(file,t)
								pbar.file_transfer_mode
							end
						},
						:progress_proc => lambda {|s|
							pbar.set s if pbar
						}) do |f|
						puts "URI: #{f.base_uri}"
						puts "Content-type: #{f.content_type}, charset: #{f.charset}"
						puts "Encoding: #{f.content_encoding}"
						puts "Last modified: #{f.last_modified}"
						puts "Status: #{f.status.inspect}"
						pp f.meta
					end
				end
			end
		rescue Exception
			#TODO: deal with any kind of exception?
			puts "Unable to get file #{$!}"
		end
	end


end
# load up grimoire data... wonder how well this will behave
#TODO: should have it passed in
historyFile="sample.yaml"
codex = Hash.new()
if File.exist?(historyFile) then
	puts "Loading up the history"
	codex = YAML.load_file(historyFile)
end

grimoire = codex.first
puts "grimoire: #{grimoire[0]}"
section = grimoire[1].first
puts "Section: #{section[0]}"
section[1].each do |spell|
	puts "Verifying Spell: #{spell[0]}"
	verify_spell(spell)
	puts "verified!"
	#sub.each do |key, value|
	#puts "key:   #{key}"
	#puts "value: #{value}"
	#end
end




if false then
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
end

puts "all done!"