require 'spec_helper'

describe SourceMage::CommandExecutor do

  before do
    @executor = SourceMage::CommandExecutor.new
  end

  it "executes commands locally" do
    @executor.run_command("hostname").should == `hostname`.strip
  end

  it "executes commands remotely" do
    @executor.run_command("root", "fallback", "hostname").should == "fallback"
  end

  it "raises an error when called incorrectly" do
    expect { @executor.run_command("hax", "hax") }.to raise_error(ArgumentError)
  end

end