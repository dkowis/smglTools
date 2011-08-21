module SourceMage
  class CommandExecutor


    def self.run_command(user, host=nil, command=nil)
      if host.nil? and command.nil?
        command = user
        return `#{command}`.strip, $?.exitstatus
      elsif user and host and command
        return `ssh #{user}@#{host} #{command}`.strip, $?.exitstatus

      else
        raise ArgumentError.new("wrong number of arguments, all three, or just one")
      end
    end
  end
end