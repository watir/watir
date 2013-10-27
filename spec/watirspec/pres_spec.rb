# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Pres" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        expect(browser.pres(:class => "c++").to_a).to eq [browser.pre(:class => "c++")]
      end
    end
  end

  describe "#length" do
    it "returns the number of pres" do
      expect(browser.pres.length).to eq 7
    end
  end

  describe "#[]" do
    it "returns the pre at the given index" do
      expect(browser.pres[1].id).to eq "rspec"
    end
  end

  describe "#each" do
    it "iterates through pres correctly" do
      count = 0

      browser.pres.each_with_index do |p, index|
        expect(p.id).to eq browser.pre(:index, index).id
        count += 1
      end

      expect(count).to be > 0
    end
  end

end
