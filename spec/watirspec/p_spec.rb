# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "P" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  # Exists method
  describe "#exist?" do
    it "returns true if the 'p' exists" do
      expect(browser.p(id: "lead")).to exist
      expect(browser.p(id: /lead/)).to exist
      expect(browser.p(text: "Dubito, ergo cogito, ergo sum.")).to exist
      expect(browser.p(text: /Dubito, ergo cogito, ergo sum/)).to exist
      expect(browser.p(class: "lead")).to exist
      expect(browser.p(class: /lead/)).to exist
      expect(browser.p(index: 0)).to exist
      expect(browser.p(xpath: "//p[@id='lead']")).to exist
    end

    it "returns the first p if given no args" do
      expect(browser.p).to exist
    end

    it "returns false if the 'p' doesn't exist" do
      expect(browser.p(id: "no_such_id")).to_not exist
      expect(browser.p(id: /no_such_id/)).to_not exist
      expect(browser.p(text: "no_such_text")).to_not exist
      expect(browser.p(text: /no_such_text/)).to_not exist
      expect(browser.p(class: "no_such_class")).to_not exist
      expect(browser.p(class: /no_such_class/)).to_not exist
      expect(browser.p(index: 1337)).to_not exist
      expect(browser.p(xpath: "//p[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.p(id: 3.14).exists? }.to raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      expect { browser.p(no_such_how: 'some_value').exists? }.to raise_error(Watir::Exception::MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#class_name" do
    it "returns the class attribute" do
      expect(browser.p(index: 0).class_name).to eq 'lead'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.p(index: 2).class_name).to eq ''
    end

    it "raises UnknownObjectException if the p doesn't exist" do
      expect { browser.p(id: 'no_such_id').class_name }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute" do
      expect(browser.p(index: 0).id).to eq "lead"
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.p(index: 2).id).to eq ''
    end

    it "raises UnknownObjectException if the p doesn't exist" do
      expect { browser.p(id: "no_such_id").id }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.p(index: 1337).id }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#title" do
    it "returns the title attribute" do
      expect(browser.p(index: 0).title).to eq 'Lorem ipsum'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.p(index: 2).title).to eq ''
    end

    it "raises UnknownObjectException if the p doesn't exist" do
      expect { browser.p(id: 'no_such_id').title }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.p(xpath: "//p[@id='no_such_id']").title }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#text" do
    it "returns the text of the p" do
      expect(browser.p(index: 1).text).to eq 'Sed pretium metus et quam. Nullam odio dolor, vestibulum non, tempor ut, vehicula sed, sapien. Vestibulum placerat ligula at quam. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.'
    end

    it "returns an empty string if the element doesn't contain any text" do
      expect(browser.p(index: 4).text).to eq ''
    end

    it "raises UnknownObjectException if the p doesn't exist" do
      expect { browser.p(id: 'no_such_id').text }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.p(:xpath , "//p[@id='no_such_id']").text }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      expect(browser.p(index: 0)).to respond_to(:class_name)
      expect(browser.p(index: 0)).to respond_to(:id)
      expect(browser.p(index: 0)).to respond_to(:title)
      expect(browser.p(index: 0)).to respond_to(:text)
    end
  end

end
