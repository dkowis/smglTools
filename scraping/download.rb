require 'digest'
require 'yaml'
require 'open-uri'
require 'pp'
require 'tempfile'
require 'progressbar'

# adding a method to string for my convinence
class String
	def starts_with?(prefix)
		prefix = prefix.to_s
		self[0, prefix.length] == prefix
	end
end

# a class to contain the spell sources
class SpellSource
	def initialize
		@urls = []
	end

	attr_accessor :file_name, :urls, :verification

	def download
		#TODO: download the file
	end

	def verify(which = :first)
		#TODO: verify the file
	end

	def verify_local
		#TODO: hardcoded /var/spool/sorcery dir right now
		local = File.join("/var/spool/sorcery", @file_name)
		if File.exists? local then
			internal_verify(local)
		else
			puts "File #{local.to_s} does not exist"
		end
	end

	def internal_verify(file)
		if @verification.starts_with? "sha512" then
			puts "verification starts with sha512"
			puts "Specified: #{@verification[@verification.index(":")..@verification.length]}"
			puts "calculated: #{Digest::SHA512.file(file).hexdigest}"
			# do the sha512 verification of the file
			@verification[@verification.index(":"),-0] == Digest::SHA512.file(file).hexdigest
		end
	end
end
	
# a class to contain the spell data
class Spell
	attr_reader :sources, :name, :version

	def parse(spell)
		#puts "=================================="
		#pp spell
		#puts "\n\n\n"

		@sources = []
		# spell name
		@name = spell[0]

		#spell data is the hash
		spell_data = spell[1]
		@version = spell_data["version"]

		# for each of the source vars do some more madness!
		spell_data["source_vars"].each do |name|
			source = SpellSource.new
			source.file_name = spell_data[name]["file_name"]
			source.verification = spell_data[name]["verification"]

			spell_data[name]["source_urls"].each do |url|
				source.urls << url
			end
			@sources << source
		end
	end
end # of Spell class

# older methods follow

def download_spell(spell)
	sourcefiles = {}
	puts "Starting download of spell"
	temp = Tempfile.new("#{spell[0]}") #spell name
	spell[1].each do |file,data|
	begin
		# yeah, my yaml code is pretty crappy at this point
		data["sources"].each.each do |source|
			source.each do |sourcevar, url|
				# download the sources for this spell
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
					# f is the file
					puts "nothing!"
				end
			end
		end
	rescue Exception
		#TODO something with the exception?
		puts "nothing!"
	end
	end
end



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
					# determine if the source file exists in /var/spool/sorcery already
					# if so, verify it
					# flag determines if it'll download it again to determine the validity of the URL
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
							# f is a File
							if data['verification'].to_s.starts_with? "sha512" then
								# compute the hash of the file and verify it
								# if it verifies, move it to /var/spool/sorcery
							end
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
	#puts "Verifying Spell: #{spell[0]}"
	#verify_spell(spell)
	#puts "verified!"
	s = Spell.new
	s.parse(spell)
	puts "Verifying local files for: #{s.name}"
	s.sources.each do |source|
		if source.verify_local then
			puts "#{source.file_name} verified"
		else
			puts "#{source.file_name} not verified"
		end
	end
	puts "\n"
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
