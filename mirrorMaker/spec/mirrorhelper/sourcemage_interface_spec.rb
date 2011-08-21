require "spec_helper"

describe SourceMage::Interface do

  before do
    @interface = SourceMage::Interface.new
  end

  it "defaults to running locally" do
    output, status = @interface.run_command("hostname")
    output.should == `hostname`.strip
  end

  it "can run commands on remote hosts" do
    #TODO: this test is very specific to my network...
    @interface.host = "fallback"
    @interface.user = "root"
    SourceMage::CommandExecutor.should_receive(:run_command).with("root", "fallback", "hostname").and_return(["fallback", 0])

    value, status = @interface.run_command("hostname")
    value.should == "fallback"
    status.should == 0
  end


  context "downloading spells" do
    it "summons a spell from a grimoire" do

      SourceMage::CommandExecutor.should_receive(:run_command).
          with("summon -g sample sample").
          and_return ["some content we ignore", 0]

      @interface.summon_spell("sample", "sample")
    end

    it "raises an error when a summon fails" do
      SourceMage::CommandExecutor.should_receive(:run_command).
          with("summon -g sample blork").
          and_return ["some content we ignore", 1]

      expect { @interface.summon_spell("sample", "blork") }.
          to raise_error SourceMage::SummonError, "Failed summoning blork from sample"
    end
  end

  context "getting information about grimoires and their spells" do

    it "lists all the grimoires available on a system" do
      @interface.host = "fallback"
      @interface.user = "root"
      SourceMage::CommandExecutor.should_receive(:run_command).
          with("root", "fallback", "gaze -q grimoires").
          and_return(["stable binary test z-rejected", 0])

      @interface.list_grimoires.should == ["stable", "binary", "test", "z-rejected"]
    end

    it "lists all the spells in the specified grimoire" do
      #load in the sample file
      file_data = File.open(File.join(File.dirname(__FILE__), "..", "sample_data", "sample.txt")) { |f| f.read }

      SourceMage::CommandExecutor.should_receive(:run_command).with("gaze -q grimoire sample").and_return [file_data, 0]

      @interface.list_spells("sample").should == %w{sample sample2 sample3 sample4 example example2 example3 example4}
    end

    it "raises an error when it cannot get a list of grimoires" do
      SourceMage::CommandExecutor.should_receive(:run_command).
          with("gaze -q grimoires").
          and_return ["content we don't care about", 1]

      expect { @interface.list_grimoires }.
          to raise_error SourceMage::GrimoireError, "Failed to list grimoires"
    end

    it "raises an error when it cannot list spells in a grimoire" do
      SourceMage::CommandExecutor.should_receive(:run_command).
          with("gaze -q grimoire sample").
          and_return ["ignored content", 1]

      expect { @interface.list_spells("sample")}.
          to raise_error SourceMage::GrimoireError, "Failed to list spells for grimoire sample"
    end
  end
end