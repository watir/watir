# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Radios" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.radios(:value => "yes").to_a.should == [browser.radio(:value => "yes")]
      end
    end
  end

  describe "#length" do
    it "returns the number of radios" do
      browser.radios.length.should == 6
    end
  end

  describe "#[]" do
    it "returns the radio button at the given index" do
      browser.radios[0].id.should == "new_user_newsletter_yes"
    end
  end

  describe "#each" do
    it "iterates through radio buttons correctly" do
      count = 0

      browser.radios.each_with_index do |r, index|
        r.name.should == browser.radio(:index, index).name
        r.id.should ==  browser.radio(:index, index).id
        r.value.should == browser.radio(:index, index).value

        count += 1
      end

      count.should > 0
    end
  end

end
