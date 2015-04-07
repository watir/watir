# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Metas" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        expect(browser.metas(name: "description").to_a).to eq [browser.meta(name: "description")]
      end
    end
  end

  describe "#length" do
    it "returns the number of meta elements" do
      expect(browser.metas.length).to eq 2
    end
  end

  describe "#[]" do
    it "returns the meta element at the given index" do
      expect(browser.metas[1].name).to eq "description"
    end
  end

  describe "#each" do
    it "iterates through meta elements correctly" do
      count = 0

      browser.metas.each_with_index do |m, index|
        expect(m.content).to eq browser.meta(index: index).content
        count += 1
      end

      expect(count).to be > 0
    end
  end

end
