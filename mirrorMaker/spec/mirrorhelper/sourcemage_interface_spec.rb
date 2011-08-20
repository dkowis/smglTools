require "spec_helper"

describe SourceMage::Interface do

  before do
    @interface = SourceMage::Interface.new
  end

  it "defaults to running locally" do
    @interface.run_command("hostname").should == `hostname`.strip
  end

  it "can run commands on remote hosts" do
    #TODO: this test is very specific to my network...
    @interface.host = "fallback"
    @interface.user = "root"
    @interface.run_command("hostname").should == "fallback"
  end

  it "lists all the spells in the specified grimoire"
  it "summons a spell from a grimoire"
  it "lists all the grimoires available on a system" do
    @interface.host = "fallback"
    @interface.user = "root"
    
    @interface.list_grimoires.should == ["stable", "binary", "test", "z-rejected"]
  end
  
end