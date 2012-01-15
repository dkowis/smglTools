require 'progressbar'
require 'open3'
require 'thread'

DOWNLOAD_THREADS = 4

class SpellPair
  attr_accessor :grimoire, :spell, :success
  
  def initialize(grimoire, spell)
    @grimoire = grimoire
    @spell = spell
    @success = false
  end

  def download
    #TODO: use POPEN3 so that I can munch off stderr and it won't be heard
    Open3.popen3(command) do |stdin, stdout, stderr, thread|
      thread.join
      if thread.value.exitstatus == 0
        @success = true
      end
    end
  end

  def command
    "summon -g #{@grimoire} #{@spell}"
  end

  def to_s
    "#{@grimoire}:#{@spell}"
  end
    
end

# get all spell names first
spell_names = Array.new
Open3.popen3(". /etc/sorcery/config; codex_get_all_spells") do |stdin, stdout, stderr, thread|
  output = stdout.read
  stderr.read
  thread.join
  unless thread.value.exitstatus == 0
    raise "Unable to get all spells"
  end
  spell_names = output.split "\n"
end
# looks like /var/lib/sorcery/codex/z-rejected/z-libs/smgl-emul32

grimoire = Hash.new

spells_to_download = Queue.new
failed_spells = Queue.new

spell_names.each do |path|
  #split path into spell name and grimoire name
  #/var/lib/sorcery/codex is the grimoire
  #wtfhax?
  unless path.include? "is not a section directory"
    triad = path.gsub("/var/lib/sorcery/codex/","")
    grimoire_name, section_name, spell_name = triad.split "/"

    grimoire[grimoire_name] ||= Hash.new
    grimoire[grimoire_name][section_name] ||= Array.new
    grimoire[grimoire_name][section_name] << spell_name
    # create pairs of stuff to download
    spells_to_download << SpellPair.new(grimoire_name, spell_name)
  end
end

# collected all spells info, now lets create a pretty progress bar
# this is reasonably dangerous, but I'll only touch progressbar from this one thread
original_size = spells_to_download.size
puts "Downloading #{original_size} spells..."
puts "Starting download with #{DOWNLOAD_THREADS} threads"

# threaded stuff starts below!
pbar = ProgressBar.new("Downloading", spells_to_download.size)
pbar_thread = Thread.new do
  # blarg
  until spells_to_download.empty?
    sleep 0.1
    pbar.set original_size - spells_to_download.size
  end
  pbar.finish
end

downloader_threads = Array.new
DOWNLOAD_THREADS.times do |x|
  downloader_threads << Thread.new do
    until spells_to_download.empty?
      spell_pair = spells_to_download.pop
      spell_pair.download
      unless spell_pair.success
        failed_spells << spell_pair
      end
    end
  end
end


downloader_threads.each do |thread|
  thread.join
end
pbar_thread.join
puts "All done downloading!"

puts "#{failed_spells.size} spells failed to download!"
failed_array = Array.new
until failed_spells.empty?
  failed_array << failed_spells.pop
end
failed_array.each do |spell_pair|
  #TODO: maybe do something more pretty
  puts "\t#{spell_pair}"
end
