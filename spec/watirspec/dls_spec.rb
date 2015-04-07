# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Dls" do

  before :each do
    browser.goto(WatirSpec.url_for("definition_lists.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        expect(browser.dls(title: "experience").to_a).to eq [browser.dl(title: "experience")]
      end
    end
  end

  describe "#length" do
    it "returns the number of dls" do
      expect(browser.dls.length).to eq 3
    end
  end

  describe "#[]" do
    it "returns the dl at the given index" do
      expect(browser.dls[0].id).to eq "experience-list"
    end
  end

  describe "#each" do
    it "iterates through dls correctly" do
      count = 0

      browser.dls.each_with_index do |d, index|
        expect(d.text).to eq browser.dl(index: index).text
        expect(d.id).to eq browser.dl(index: index).id
        expect(d.class_name).to eq browser.dl(index: index).class_name

        count += 1
      end

      expect(count).to be > 0
    end
  end

end
