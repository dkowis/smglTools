require 'yaml'
require 'find'
require 'fileutils'

movieDir="/srv/media/test/vids"
baseDir="/srv/media"
completeDir="#{baseDir}/completed"
processingDir="#{baseDir}/processing"

# theifed from http://snippets.dzone.com/posts/show/5811
class Hash
  # Replacing the to_yaml function so it'll serialize hashes sorted (by their keys)
  #
  # Original function is in /usr/lib/ruby/1.8/yaml/rubytypes.rb
  def to_yaml( opts = {} )
    YAML::quick_emit( object_id, opts ) do |out|
      out.map( taguri, to_yaml_style ) do |map|
        sort.each do |k, v|   # <-- here's my addition (the 'sort')
          map.add( k, v )
        end
      end
    end
  end
end


def titleCase(string) 
	line = string
	small_re = %w( a an and as at but by en for if in of on or the to via v[.]? vs[.]? ).join('|');

	# split line into phrases
	line = line.split(/( [:.;?!][ ] | (?:[ ]|^)[".] )/x).collect do |s|
		# Uppercase all non-dotted (e.g. del.icio.us) words for now
		s.gsub(/\b([[:alpha:]][[:lower:].'.]*)\b/ex) do |w|
			w.match(/[[:alpha:]] [.] [[:alpha:]] /x) ? w : w.capitalize
		end.

		# Lowercase our list of small words:
		gsub(/\b(#{small_re})\b/i) {|w| w.downcase }.

		# If the first word in the title is a small word, then capitalize it:
		gsub(/\A([[:punct:]]*)(#{small_re})\b/io) { $1 + $2.capitalize}.

		# If the last word in the title is a small word, then capitalize it:
		gsub(/\b(#{small_re})([[:punct:]]*)\Z/io) { $1.capitalize + $2}
	end.join.

	# Special Cases
	gsub(/ V(s?)[.] /, ' v\1. ').               # "v." and "vs.":
	gsub(/(['.])S\b/, '\1s').                   # 'S (otherwise you get "the SEC'S decision")
	gsub(/\b(AT&T|Q&A)\b/i) {|s| s.upcase}      # "AT&T" and "Q&A", which get tripped up by

	line;
end


# load up encoded movies!
historyFile="#{baseDir}/EncodeHistory.yml"
h = Hash.new()
if File.exist?(historyFile) then
	puts "Loading up the history"
	h = YAML.load_file(historyFile)
end
if !h then 
	h =Hash.new()
end

previousMovie=""
Dir.glob(movieDir + "/**/VTS*.vob",File::FNM_CASEFOLD).each do |vobFile|
	interrupted = false
	magicArray = vobFile.split("/")
	movieName=magicArray[magicArray.count-3]
	moviePath="/" + magicArray.values_at(1..magicArray.count-3).join("/")
	if movieName != previousMovie then
		previousMovie = movieName
		movieTitle = titleCase(movieName.downcase.tr('_',' '))
		# new movie
		# check to see if the movie exists in the complete dir
		# if it doesn't exist, or it was interrupted
		if !h.has_key?(movieTitle) or h[movieTitle][:interrupted] == true then
			h[movieTitle] = Hash.new();
			
			# record start time
			h[movieTitle][:start] = Time.now
			
			command = "HandBrakeCLI -i \"#{moviePath}\" -L -N eng -m -o \"#{processingDir}/#{movieTitle}.mp4\" -e x264 -b 2500 -a 1 -E faac -B 160 -R 48 -6 dpl2 -f mp4 --crop 0:0:0:0 --strict-anamorphic -x level=41:me=umh"
			#command = "sleep 1"
			completed = system command

			# record end time
			h[movieTitle][:end] = Time.now
			if completed == true then
				puts "Processing Completed Successfully for #{movieTitle}"
				elapsed = h[movieTitle][:end] - h[movieTitle][:start]
				h[movieTitle][:elapsed] = elapsed
				puts "Processing took #{Time.at(elapsed).gmtime.strftime('%R:%S')}"
				if File.exist?("#{processingDir}/#{movieTitle}.mp4") then
					puts "Moving #{movieTitle} into completed directory!"
					FileUtils.mv("#{processingDir}/#{movieTitle}.mp4","#{completeDir}/#{movieTitle}.mp4")
					h[movieTitle][:status] = "Success"
				else
					puts "!!!! No encoded file exists! not recording!"
					h[movieTitle][:status] = "Failure"
				end
			else
				if $? == 2 then
					# SIGINT!
					interrupted = true
					h[movieTitle][:interrupted] = true
				end
				# determine how it exited?
				puts "Failed to encode #{movieTitle}, recording it in the history"
				h[movieTitle][:status] = "Failure"
			end
			# write out the YAML after each encode
			File.open("#{historyFile}", 'w') { |f| YAML.dump(h, f) }
		else
			if h[movieTitle][:status] ==  "Success" then
				puts "#{movieTitle} was previously successfully encoded"
			else 
				puts "#{movieTitle} was previously attempted, but failed to encode"
			end
		end
		if interrupted then
			raise "Interrupted by user!"
		end
	end
end
