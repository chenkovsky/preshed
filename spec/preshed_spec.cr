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
    map[str.hash].should eq(Pointer(UInt8).null)
    (1...1000).each do |i|
      map[i.hash] = Pointer(UInt8).new(i)
    end

    (1...1000).each do |i|
      map[i.hash].should eq(Pointer(UInt8).new(i))
    end
    map.size.should eq(999)
  end

  it "save load" do
    map = Preshed::Map(UInt8*).new(Pointer(UInt8).null)
    (1...1000).each do |i|
      map[i.hash] = Pointer(UInt8).new(i)
    end
    map.to_disk("tmp.bin") do |v, io, format|
      (v.address).to_io io, format
    end
    map2 = Preshed::Map(UInt8*).from_disk("tmp.bin") do |io, format|
      Pointer(UInt8).new(UInt64.from_io io, format)
    end
    map2.size.should eq(map.size)
    (1...1000).each do |i|
      map[i.hash].should eq(map2[i.hash])
    end
  end

  it "save load2" do
    map = Preshed::Map(Int32).new(0)
    (1...1000).each do |i|
      map[i.hash] = i
    end
    map.to_disk("tmp.bin")
    map2 = Preshed::Map(Int32).from_disk("tmp.bin")
    map2.size.should eq(map.size)
    (1...1000).each do |i|
      map[i.hash].should eq(map2[i.hash])
    end
  end
  it "clear" do
    map = Preshed::Map(UInt8*).new(Pointer(UInt8).null)
    (1...1000).each do |i|
      map[i.hash] = Pointer(UInt8).new(i)
    end
    map.size.should eq(999)
    map.clear
    map.size.should eq(0)
    (1...1000).each do |i|
      map[i.hash].should eq(Pointer(UInt8).null)
    end
  end
end
