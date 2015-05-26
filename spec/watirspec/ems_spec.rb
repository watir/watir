# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Ems" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        expect(browser.ems(class: "important-class").to_a).to eq [browser.em(class: "important-class")]
      end
    end
  end

  describe "#length" do
    it "returns the number of ems" do
      expect(browser.ems.length).to eq 1
    end
  end

  describe "#[]" do
    it "returns the em at the given index" do
      expect(browser.ems[0].id).to eq "important-id"
    end
  end

  describe "#each" do
    it "iterates through ems correctly" do
      count = 0

      browser.ems.each_with_index do |e, index|
        expect(e.text).to eq browser.em(index: index).text
        expect(e.id).to eq browser.em(index: index).id
        expect(e.class_name).to eq browser.em(index: index).class_name

        count += 1
      end

      expect(count).to be > 0
    end
  end

end
