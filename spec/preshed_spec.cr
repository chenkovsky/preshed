require "./spec_helper"

describe Preshed do
  # TODO: Write tests

  it "works" do
    map = Preshed::Map(UInt8*).new(Pointer(UInt8).null)
    str = "呵呵"
    map[str.hash] = str.to_unsafe
    map[str.hash].should eq(str.to_unsafe)
    map.size.should eq(1)
    map.delete(str.hash).should eq(str.to_unsafe)
    map.size.should eq(0)
    map[str.hash]?.should eq(nil)
    (1...1000).each do |i|
      map[i.hash] = Pointer(UInt8).new(i)
    end

    (1...1000).each do |i|
      map[i.hash].should eq(Pointer(UInt8).new(i))
    end
    map.size.should eq(999)
  end
end
