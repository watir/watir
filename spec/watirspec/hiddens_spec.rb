# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Hiddens" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.hiddens(:value => "dolls").to_a.should == [browser.hidden(:value => "dolls")]
      end
    end
  end
  
  describe "#length" do
    it "returns the number of hiddens" do
      browser.hiddens.length.should == 1
    end
  end

  describe "#[]" do
    it "returns the Hidden at the given index" do
      browser.hiddens[0].id.should == "new_user_interests_dolls"
    end
  end

  describe "#each" do
    it "iterates through hiddens correctly" do
      count = 0

      browser.hiddens.each_with_index do |h, index|
        h.name.should == browser.hidden(:index, index).name
        h.id.should == browser.hidden(:index, index).id
        h.value.should == browser.hidden(:index, index).value

        count += 1
      end

      count.should > 0
    end
  end

end
