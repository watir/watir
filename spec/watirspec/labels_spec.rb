# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Labels" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.labels(:for => "new_user_first_name").to_a.should == [browser.label(:for => "new_user_first_name")]
      end
    end
  end

  describe "#length" do
    it "returns the number of labels" do
      browser.labels.length.should == 31
    end
  end

  describe "#[]" do
    it "returns the label at the given index" do
      browser.labels[0].id.should == "first_label"
    end
  end

  describe "#each" do
    it "iterates through labels correctly" do
      count = 0

      browser.labels.each_with_index do |l, index|
        l.id.should == browser.label(:index, index).id
        count += 1
      end

      count.should > 0
    end
  end

end
