require "spec_helper"

describe SourceMage::Mirror do
  
  it "summons all the spells from each grimoire" do
    mirror = SourceMage::Mirror.new

    interface = double(SourceMage::Interface)

    SourceMage::Interface.should_receive(:new).and_return(interface)

    data = {
        sample: %w{sample1 sample2 sample3},
        sample2: %w{example1 example2 example3}
    }

    puts data.keys
    interface.should_receive(:list_grimoires).and_return(data.keys)
    interface.should_receive(:list_spells).with("sample").and_return(%w{sample1 sample2 sample3})
    interface.should_receive(:list_spells).with("sample2").and_return(%w{example1 example2 example3})



    expect { mirror.mirror }.
        not_to raise_error
  end

  context "after a mirror run" do
    it "supplies a list of failed downloads"
    it "supplies a list of downloaded spells"
  end
end