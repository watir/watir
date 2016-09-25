# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Pre" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  # Exists method
  describe "#exist?" do
    it "returns true if the 'p' exists" do
      expect(browser.pre(id: "rspec")).to exist
      expect(browser.pre(id: /rspec/)).to exist
      expect(browser.pre(text: 'browser.pre(id: "rspec").should exist')).to exist
      expect(browser.pre(text: /browser\.pre/)).to exist
      expect(browser.pre(class: "ruby")).to exist
      expect(browser.pre(class: /ruby/)).to exist
      expect(browser.pre(index: 0)).to exist
      expect(browser.pre(xpath: "//pre[@id='rspec']")).to exist
    end

    it "returns the first pre if given no args" do
      expect(browser.pre).to exist
    end

    it "returns false if the 'p' doesn't exist" do
      expect(browser.pre(id: "no_such_id")).to_not exist
      expect(browser.pre(id: /no_such_id/)).to_not exist
      expect(browser.pre(text: "no_such_text")).to_not exist
      expect(browser.pre(text: /no_such_text/)).to_not exist
      expect(browser.pre(class: "no_such_class")).to_not exist
      expect(browser.pre(class: /no_such_class/)).to_not exist
      expect(browser.pre(index: 1337)).to_not exist
      expect(browser.pre(xpath: "//pre[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.pre(id: 3.14).exists? }.to raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      expect { browser.pre(no_such_how: 'some_value').exists? }.to raise_error(Watir::Exception::MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#class_name" do
    it "returns the class attribute" do
      expect(browser.pre(id: 'rspec').class_name).to eq 'ruby'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.pre(index: 0).class_name).to eq ''
    end

    it "raises UnknownObjectException if the p doesn't exist" do
      expect { browser.pre(id: 'no_such_id').class_name }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute" do
      expect(browser.pre(class: 'ruby').id).to eq "rspec"
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.pre(index: 0).id).to eq ''
    end

    it "raises UnknownObjectException if the pre doesn't exist" do
      expect { browser.pre(id: "no_such_id").id }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.pre(index: 1337).id }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#title" do
    it "returns the title attribute" do
      expect(browser.pre(class: 'brainfuck').title).to eq 'The brainfuck language is an esoteric programming language noted for its extreme minimalism'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.pre(index: 0).title).to eq ''
    end

    it "raises UnknownObjectException if the pre doesn't exist" do
      expect { browser.pre(id: 'no_such_id').title }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.pre(xpath: "//pre[@id='no_such_id']").title }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#text" do
    it "returns the text of the pre" do
      expect(browser.pre(class: 'haskell').text).to eq 'main = putStrLn "Hello World"'
    end

    it "returns an empty string if the element doesn't contain any text" do
      expect(browser.pre(index: 0).text).to eq ''
    end

    it "raises UnknownObjectException if the pre doesn't exist" do
      expect { browser.pre(id: 'no_such_id').text }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.pre(:xpath , "//pre[@id='no_such_id']").text }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      expect(browser.image(index: 0)).to respond_to(:class_name)
      expect(browser.image(index: 0)).to respond_to(:id)
      expect(browser.image(index: 0)).to respond_to(:title)
      expect(browser.image(index: 0)).to respond_to(:text)
    end
  end

end
