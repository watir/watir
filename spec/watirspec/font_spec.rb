# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Font" do

  before :each do
    browser.goto(WatirSpec.url_for("font.html"))
  end
  
  bug "http://github.com/jarib/celerity/issues#issue/29", :celerity do
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
      browser.font(:index, 0).size.should == "12"
    end

    it "finds all font elements" do
      browser.fonts.size.should == 1
    end
  end

end
