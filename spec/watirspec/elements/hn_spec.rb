require 'watirspec_helper'

describe ['H1', 'H2', 'H3', 'H4', 'H5', 'H6'] do
  before :each do
    browser.goto(WatirSpec.url_for('non_control_elements.html'))
  end

  # Exists method
  describe '#exist?' do
    it 'returns true if the element exists' do
      expect(browser.h1(id: 'header1')).to exist
      expect(browser.h2(id: /header2/)).to exist
      expect(browser.h3(text: 'Header 3')).to exist
      expect(browser.h4(text: /Header 4/)).to exist
      expect(browser.h5(index: 0)).to exist
      expect(browser.h6(index: 0)).to exist
      expect(browser.h1(xpath: "//h1[@id='first_header']")).to exist
    end

    it 'returns the first h1 if given no args' do
      expect(browser.h1).to exist
    end

    it 'returns true if the element exists' do
      expect(browser.h1(id: 'no_such_id')).to_not exist
      expect(browser.h1(id: /no_such_id/)).to_not exist
      expect(browser.h1(text: 'no_such_text')).to_not exist
      expect(browser.h1(text: /no_such_text 1/)).to_not exist
      expect(browser.h1(index: 1337)).to_not exist
      expect(browser.h1(xpath: "//p[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.h1(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  # Attribute methods
  describe '#id' do
    it 'returns the id attribute' do
      expect(browser.h1(index: 0).id).to eq 'first_header'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.h3(index: 0).id).to eq ''
    end

    it "raises UnknownObjectException if the p doesn't exist" do
      expect { browser.h1(id: 'no_such_id').id }.to raise_unknown_object_exception
      expect { browser.h1(index: 1337).id }.to raise_unknown_object_exception
    end
  end

  describe '#text' do
    it 'returns the text of the element' do
      expect(browser.h1(index: 0).text).to eq 'Header 1'
    end

    it "returns an empty string if the element doesn't contain any text" do
      expect(browser.h6(id: 'empty_header').text).to eq ''
    end

    it "raises UnknownObjectException if the p doesn't exist" do
      expect { browser.h1(id: 'no_such_id').text }.to raise_unknown_object_exception
      expect { browser.h1(xpath: "//h1[@id='no_such_id']").text }.to raise_unknown_object_exception
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.h1(index: 0)).to respond_to(:class_name)
      expect(browser.h1(index: 0)).to respond_to(:id)
      expect(browser.h1(index: 0)).to respond_to(:text)
    end
  end
end
