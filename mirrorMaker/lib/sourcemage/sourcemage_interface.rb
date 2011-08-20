module SourceMage
  class Interface

    attr_accessor :host
    attr_accessor :user

    def initialize
      @user = "mirrorhelper"
    end


    def list_grimoires
      run_command("gaze -q grimoires").split(" ")
    end

    def run_command(command)
      if @host.nil?
        `#{command}`.strip
      else
        `ssh #{@user}@#{@host} #{command}`.strip
      end
    end

  end
end