# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Span" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  # Exists method
  describe "#exist?" do
    it "returns true if the 'span' exists" do
      expect(browser.span(id: "lead")).to exist
      expect(browser.span(id: /lead/)).to exist
      expect(browser.span(text: "Dubito, ergo cogito, ergo sum.")).to exist
      expect(browser.span(text: /Dubito, ergo cogito, ergo sum/)).to exist
      expect(browser.span(class: "lead")).to exist
      expect(browser.span(class: /lead/)).to exist
      expect(browser.span(index: 0)).to exist
      expect(browser.span(xpath: "//span[@id='lead']")).to exist
    end

    it "returns the first span if given no args" do
      expect(browser.span).to exist
    end

    it "returns false if the element doesn't exist" do
      expect(browser.span(id: "no_such_id")).to_not exist
      expect(browser.span(id: /no_such_id/)).to_not exist
      expect(browser.span(text: "no_such_text")).to_not exist
      expect(browser.span(text: /no_such_text/)).to_not exist
      expect(browser.span(class: "no_such_class")).to_not exist
      expect(browser.span(class: /no_such_class/)).to_not exist
      expect(browser.span(index: 1337)).to_not exist
      expect(browser.span(xpath: "//span[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.span(id: 3.14).exists? }.to raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      expect { browser.span(no_such_how: 'some_value').exists? }.to raise_error(Watir::Exception::MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#class_name" do
    it "returns the class attribute" do
      expect(browser.span(index: 0).class_name).to eq 'lead'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.span(index: 2).class_name).to eq ''
    end

    it "raises UnknownObjectException if the span doesn't exist" do
      expect { browser.span(id: 'no_such_id').class_name }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute" do
      expect(browser.span(index: 0).id).to eq "lead"
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.span(index: 2).id).to eq ''
    end

    it "raises UnknownObjectException if the span doesn't exist" do
      expect { browser.span(id: "no_such_id").id }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.span(index: 1337).id }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#title" do
    it "returns the title attribute" do
      expect(browser.span(index: 0).title).to eq 'Lorem ipsum'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.span(index: 2).title).to eq ''
    end

    it "raises UnknownObjectException if the span doesn't exist" do
      expect { browser.span(id: 'no_such_id').title }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.span(xpath: "//span[@id='no_such_id']").title }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#text" do
    it "returns the text of the span" do
      expect(browser.span(index: 1).text).to eq 'Sed pretium metus et quam. Nullam odio dolor, vestibulum non, tempor ut, vehicula sed, sapien. Vestibulum placerat ligula at quam. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.'
    end

    it "returns an empty string if the element doesn't contain any text" do
      expect(browser.span(index: 4).text).to eq ''
    end

    it "raises UnknownObjectException if the span doesn't exist" do
      expect { browser.span(id: 'no_such_id').text }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.span(:xpath , "//span[@id='no_such_id']").text }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      expect(browser.span(index: 0)).to respond_to(:class_name)
      expect(browser.span(index: 0)).to respond_to(:id)
      expect(browser.span(index: 0)).to respond_to(:title)
      expect(browser.span(index: 0)).to respond_to(:text)
    end
  end

  # Other
  describe "#click" do
    it "fires events" do
      expect(browser.span(class: 'footer').text).to_not include('Javascript')
      browser.span(class: 'footer').click
      expect(browser.span(class: 'footer').text).to include('Javascript')
    end

    it "raises UnknownObjectException if the span doesn't exist" do
      expect { browser.span(id: "no_such_id").click }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.span(title: "no_such_title").click }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

end
