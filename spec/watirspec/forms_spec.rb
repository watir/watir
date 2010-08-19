# encoding: utf-8
require File.expand_path('spec_helper', File.dirname(__FILE__))

describe "Forms" do

  before :each do
    browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
  end

  describe "#length" do
    it "returns the number of forms in the container" do
      browser.forms.length.should == 2
    end
  end

  describe "#[]n" do
    it "provides access to the nth form" do
      browser.forms[0].action.should == 'post_to_me'
      browser.forms[0].attribute_value('method').should == 'post'
    end
  end

  describe "#each" do
    it "iterates through forms correctly" do
      browser.forms.each_with_index do |f, index|
        f.name.should == browser.form(:index, index).name
        f.id.should == browser.form(:index, index).id
        f.class_name.should == browser.form(:index, index).class_name
      end
    end
  end

end
