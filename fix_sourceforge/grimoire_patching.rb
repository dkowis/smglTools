#!/usr/bin/env ruby

FIND=/\$SOURCEFORGE_URL\/\$\{?SPELL\}?\/\$\{?SOURCE\}?/

test = "$SOURCEFORGE_URL/$SPELL/${SOURCE}"

Dir.glob("*/*/DETAILS").each do |file|
    begin
        text = File.read(file)
        if text.match FIND
            puts "Patching #{file}"
            new_text = text.gsub(FIND, "$SOURCEFORGE_URL/$SPELL/$SPELL/$SOURCE")
            File.open(file, 'w') { |f| f.puts new_text }
        end
    rescue Exception => e
        # bleh?
    end
end