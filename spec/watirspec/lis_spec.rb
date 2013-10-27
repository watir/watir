# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Lis" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        expect(browser.lis(:class => "nonlink").to_a).to eq [browser.li(:class => "nonlink")]
      end
    end
  end

  describe "#length" do
    it "returns the number of lis" do
      expect(browser.lis.length).to eq 18
    end
  end

  describe "#[]" do
    it "returns the li at the given index" do
      expect(browser.lis[4].id).to eq "non_link_1"
    end
  end

  describe "#each" do
    it "iterates through lis correctly" do
      count = 0

      browser.lis.each_with_index do |l, index|
        expect(l.id).to eq browser.li(:index, index).id
        expect(l.value).to eq browser.li(:index, index).value

        count += 1
      end

      expect(count).to be > 0
    end
  end

end
