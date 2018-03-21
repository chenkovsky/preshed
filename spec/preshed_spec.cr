require "./spec_helper"

describe Preshed do
  # TODO: Write tests

  it "works" do
    map = Preshed::Map.new
    str = "呵呵"
    map[str.hash] = pointerof(str).as(Void*)
    map[str.hash].should eq(pointerof(str).as(Void*))
    map.size.should eq(1)
    map.delete(str.hash).should eq(pointerof(str).as(Void*))
    map.size.should eq(0)
    map[str.hash]?.should eq(nil)
    (1...1000).each do |i|
      map[i.hash] = Pointer(Void).new(i)
    end

    (1...1000).each do |i|
      map[i.hash].should eq(Pointer(Void).new(i))
    end
    map.size.should eq(999)
  end
end
