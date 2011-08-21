module SourceMage
  class Interface

    attr_accessor :host
    attr_accessor :user

    def initialize
      @user = "mirrorhelper"
    end


    def list_grimoires
      content, status = run_command("gaze -q grimoires")
      if status != 0
        raise GrimoireError.new("Failed to list grimoires")
      end
      content.split " "
    end

    def list_spells(grimoire)
      content, status = run_command("gaze -q grimoire #{grimoire}")
      if status != 0
        raise GrimoireError.new("Failed to list spells for grimoire #{grimoire}")
      end
      spells = []
      content.split("\n").each do |line|
        line.strip!
        if !(line.empty? or line.start_with? "Grimoire" or line.start_with? "SECTION" or line.start_with? "Total spells")
          spells << line
        end
      end
      spells
    end

    def summon_spell(grimoire, spell)
      content,value = run_command("summon -g #{grimoire} #{spell}")
      if value != 0
        raise SummonError.new("Failed summoning #{spell} from #{grimoire}")
      end
    end

    def run_command(command)
      if @host.nil?
        value, status = CommandExecutor.run_command(command)
      else
        value, status = CommandExecutor.run_command(@user, @host, command)
      end
      return value, status
    end

  end
end