require "spec_helper"

describe SourceMage::Mirror do
  
  it "summons all the spells from each grimoire" do
    mirror = SourceMage::Mirror.new

    pending "not done yet! Mock up all the things and describe the execution"

    expect { mirror.mirror }.
        not_to raise_error
  end

  context "after a mirror run" do
    it "supplies a list of failed downloads"
    it "supplies a list of downloaded spells"
  end
end