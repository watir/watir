# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "FileFields" do

  before :each do
    browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
  end

  describe "#length" do
    it "returns the correct number of file fields" do
      browser.file_fields.length.should == 2
    end
  end

  describe "#[]" do
    it "returns the file field at the given index" do
      browser.file_fields[1].id.should == "new_user_portrait"
    end
  end

  describe "#each" do
    it "iterates through file fields correctly" do
      count = 0

      browser.file_fields.each_with_index do |f, index|
        f.name.should == browser.file_field(:index, index+1).name
        f.id.should ==  browser.file_field(:index, index+1).id
        f.value.should == browser.file_field(:index, index+1).value

        count += 1
      end

      count.should > 0
    end
  end

end
