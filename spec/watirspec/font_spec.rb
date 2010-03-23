# encoding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

describe "Font" do

  before :each do
    browser.goto(WatirSpec.files + "/font.html")
  end

  it "finds the font element" do
    browser.font(:index, 0).should exist
  end

  it "knows about the color attribute" do
    browser.font(:index, 0).color.should == "#ff00ff"
  end

  it "knows about the face attribute" do
    browser.font(:index, 0).face.should == "Helvetica"
  end

  it "knows about the size attribute" do
    browser.font(:index, 0).size.should == 12
  end

end
