# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Uls" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        expect(browser.uls(class: "navigation").to_a).to eq [browser.ul(class: "navigation")]
      end
    end
  end

  describe "#length" do
    it "returns the number of uls" do
      expect(browser.uls.length).to eq 2
    end
  end

  describe "#[]" do
    it "returns the ul at the given index" do
      expect(browser.uls[0].id).to eq "navbar"
    end
  end

  describe "#each" do
    it "iterates through uls correctly" do
      count = 0

      browser.uls.each_with_index do |ul, index|
        expect(ul.id).to eq browser.ul(index: index).id
        count += 1
      end

      expect(count).to be > 0
    end
  end
end
