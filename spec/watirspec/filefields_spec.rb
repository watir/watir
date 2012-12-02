# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "FileFields" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.file_fields(:class => "portrait").to_a.should == [browser.file_field(:class => "portrait")]
      end
    end
  end

  describe "#length" do
    it "returns the correct number of file fields" do
      browser.file_fields.length.should == 3
    end
  end

  describe "#[]" do
    it "returns the file field at the given index" do
      browser.file_fields[0].id.should == "new_user_portrait"
    end
  end

  describe "#each" do
    it "iterates through file fields correctly" do
      count = 0

      browser.file_fields.each_with_index do |f, index|
        f.name.should == browser.file_field(:index, index).name
        f.id.should ==  browser.file_field(:index, index).id
        f.value.should == browser.file_field(:index, index).value

        count += 1
      end

      count.should > 0
    end
  end

end
