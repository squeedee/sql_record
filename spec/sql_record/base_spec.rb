require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe SQLRecord::Base do

  describe "created" do
    it { should respond_to(:raw_attributes) }
    it { should_not respond_to(:raw_attributes=)}
  end


  describe "initialized without an attributes hash" do
    its("raw_attributes") { should == {} }
  end

  describe "initialized with a raw_attributes" do
    subject { SQLRecord::Base.new 'a'=>'my_record' }
    its("raw_attributes") { should == {'a' => 'my_record'} }
  end


end