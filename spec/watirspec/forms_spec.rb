# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Forms" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.forms(:method => "post").to_a.should == [browser.form(:method => "post")]
      end
    end
  end

  describe "#length" do
    it "returns the number of forms in the container" do
      browser.forms.length.should == 2
    end
  end

  describe "#[]n" do
    it "provides access to the nth form" do
      browser.forms[0].action.should =~ /post_to_me$/ # varies between browsers
      browser.forms[0].attribute_value('method').should == 'post'
    end
  end

  describe "#each" do
    it "iterates through forms correctly" do
      count = 0

      browser.forms.each_with_index do |f, index|
        f.name.should == browser.form(:index, index).name
        f.id.should == browser.form(:index, index).id
        f.class_name.should == browser.form(:index, index).class_name

        count += 1
      end

      count.should > 0
    end
  end

end
