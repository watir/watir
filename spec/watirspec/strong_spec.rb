# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Strong" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  # Exists method
  describe "#exist?" do
    it "returns true if the element exists" do
      expect(browser.strong(id: "descartes")).to exist
      expect(browser.strong(id: /descartes/)).to exist
      expect(browser.strong(text: "Dubito, ergo cogito, ergo sum.")).to exist
      expect(browser.strong(text: /Dubito, ergo cogito, ergo sum/)).to exist
      expect(browser.strong(class: "descartes")).to exist
      expect(browser.strong(class: /descartes/)).to exist
      expect(browser.strong(index: 0)).to exist
      expect(browser.strong(xpath: "//strong[@id='descartes']")).to exist
    end

    it "returns the first strong if given no args" do
      expect(browser.strong).to exist
    end

    it "returns false if the element doesn't exist" do
      expect(browser.strong(id: "no_such_id")).to_not exist
      expect(browser.strong(id: /no_such_id/)).to_not exist
      expect(browser.strong(text: "no_such_text")).to_not exist
      expect(browser.strong(text: /no_such_text/)).to_not exist
      expect(browser.strong(class: "no_such_class")).to_not exist
      expect(browser.strong(class: /no_such_class/)).to_not exist
      expect(browser.strong(index: 1337)).to_not exist
      expect(browser.strong(xpath: "//strong[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.strong(id: 3.14).exists? }.to raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      expect { browser.strong(no_such_how: 'some_value').exists? }.to raise_error(Watir::Exception::MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#class_name" do
    it "returns the class attribute" do
      expect(browser.strong(index: 0).class_name).to eq 'descartes'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.strong(index: 1).class_name).to eq ''
    end

    it "raises UnknownObjectException if the element doesn't exist" do
      expect { browser.strong(id: 'no_such_id').class_name }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute" do
      expect(browser.strong(index: 0).id).to eq "descartes"
    end

    it "raises UnknownObjectException if the element doesn't exist" do
      expect { browser.strong(id: "no_such_id").id }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.strong(index: 1337).id }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#text" do
    it "returns the text of the element" do
      expect(browser.strong(index: 0).text).to eq "Dubito, ergo cogito, ergo sum."
    end

    it "raises UnknownObjectException if the element doesn't exist" do
      expect { browser.strong(id: 'no_such_id').text }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.strong(:xpath , "//strong[@id='no_such_id']").text }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      expect(browser.strong(index: 0)).to respond_to(:class_name)
      expect(browser.strong(index: 0)).to respond_to(:id)
      expect(browser.strong(index: 0)).to respond_to(:text)
    end
  end

  # Other
end
