require 'spec_helper'

describe SourceMage::CommandExecutor do

  before do
    @executor = SourceMage::CommandExecutor
  end

  it "executes commands locally" do
    hostname, result = @executor.run_command("hostname")
    hostname.should == "raziel.shlrm.org"
    result.should == 0
  end

  it "executes commands remotely" do
    value, result = @executor.run_command("root", "fallback", "hostname")
    value.should == "fallback"
    result.should == 0
  end

  it "raises an error when called incorrectly" do
    expect { @executor.run_command("hax", "hax") }.to raise_error(ArgumentError)
  end

  it "can run a command and return the error code also" do
    output, status = @executor.run_command("false")

    output.should be_empty
    status.should == 1
  end

end