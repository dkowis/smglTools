module SourceMage
  class CommandExecutor


    def run_command(user, host=nil, command=nil)
      if host.nil? and command.nil?
        command = user
        `#{command}`.strip
      elsif user and host and command
        `ssh #{user}@#{host} #{command}`.strip

      else
        raise ArgumentError.new("wrong number of arguments, all three, or just one")
      end
    end
  end
end