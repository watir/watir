# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Collections" do

  before :each do
    browser.goto(WatirSpec.url_for("collections.html"))
  end

  it "returns inner elements of parent element having different html tag" do
    browser.span(:id => "a_span").divs.size.should == 2
  end

  it "returns inner elements of parent element having same html tag" do
    browser.span(:id => "a_span").spans.size.should == 2
  end
end
