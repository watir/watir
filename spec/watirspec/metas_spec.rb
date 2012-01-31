# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Metas" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.metas(:name => "description").to_a.should == [browser.meta(:name => "description")]
      end
    end
  end
  
  describe "#length" do
    it "returns the number of meta elements" do
      browser.metas.length.should == 2
    end
  end

  describe "#[]" do
    it "returns the meta element at the given index" do
      browser.metas[1].name.should == "description"
    end
  end

  describe "#each" do
    it "iterates through meta elements correctly" do
      count = 0

      browser.metas.each_with_index do |m, index|
        m.content.should == browser.meta(:index, index).content
        count += 1
      end

      count.should > 0
    end
  end

end
