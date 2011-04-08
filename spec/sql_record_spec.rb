require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SQLRecord" do
  it "should define Base" do
     defined?(SQLRecord::Base).should be_true
  end

  it "should define Attributes::Mapper" do
     defined?(SQLRecord::Attributes::Mapper).should be_true
  end

  it "should define SanitizedQuery" do
     defined?(SQLRecord::SanitizedQuery).should be_true
  end

end
