# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Del" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  # Exists method
  describe "#exist?" do
    it "returns true if the 'del' exists" do
      expect(browser.del(id: "lead")).to exist
      expect(browser.del(id: /lead/)).to exist
      expect(browser.del(text: "This is a deleted text tag 1")).to exist
      expect(browser.del(text: /This is a deleted text tag 1/)).to exist
      expect(browser.del(class: "lead")).to exist
      expect(browser.del(class: /lead/)).to exist
      expect(browser.del(index: 0)).to exist
      expect(browser.del(xpath: "//del[@id='lead']")).to exist
    end

    it "returns the first del if given no args" do
      expect(browser.del).to exist
    end

    it "returns false if the element doesn't exist" do
      expect(browser.del(id: "no_such_id")).to_not exist
      expect(browser.del(id: /no_such_id/)).to_not exist
      expect(browser.del(text: "no_such_text")).to_not exist
      expect(browser.del(text: /no_such_text/)).to_not exist
      expect(browser.del(class: "no_such_class")).to_not exist
      expect(browser.del(class: /no_such_class/)).to_not exist
      expect(browser.del(index: 1337)).to_not exist
      expect(browser.del(xpath: "//del[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.del(id: 3.14).exists? }.to raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      expect { browser.del(no_such_how: 'some_value').exists? }.to raise_error(Watir::Exception::MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#class_name" do
    it "returns the class attribute" do
      expect(browser.del(index: 0).class_name).to eq 'lead'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.del(index: 2).class_name).to eq ''
    end

    it "raises UnknownObjectException if the del doesn't exist" do
      expect { browser.del(id: 'no_such_id').class_name }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute" do
      expect(browser.del(index: 0).id).to eq "lead"
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.del(index: 2).id).to eq ''
    end

    it "raises UnknownObjectException if the del doesn't exist" do
      expect { browser.del(id: "no_such_id").id }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.del(index: 1337).id }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#title" do
    it "returns the title attribute" do
      expect(browser.del(index: 0).title).to eq 'Lorem ipsum'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.del(index: 2).title).to eq ''
    end

    it "raises UnknownObjectException if the del doesn't exist" do
      expect { browser.del(id: 'no_such_id').title }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.del(xpath: "//del[@id='no_such_id']").title }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#text" do
    it "returns the text of the del" do
      expect(browser.del(index: 1).text).to eq 'This is a deleted text tag 2'
    end

    it "returns an empty string if the element doesn't contain any text" do
      expect(browser.del(index: 3).text).to eq ''
    end

    it "raises UnknownObjectException if the del doesn't exist" do
      expect { browser.del(id: 'no_such_id').text }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.del(:xpath , "//del[@id='no_such_id']").text }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      expect(browser.del(index: 0)).to respond_to(:class_name)
      expect(browser.del(index: 0)).to respond_to(:id)
      expect(browser.del(index: 0)).to respond_to(:title)
      expect(browser.del(index: 0)).to respond_to(:text)
    end
  end

  # Other
  describe "#click" do
    it "fires events" do
      expect(browser.del(class: 'footer').text).to_not include('Javascript')
      browser.del(class: 'footer').click
      expect(browser.del(class: 'footer').text).to include('Javascript')
    end

    it "raises UnknownObjectException if the del doesn't exist" do
      expect { browser.del(id: "no_such_id").click }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.del(title: "no_such_title").click }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end
end
