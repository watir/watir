require 'watirspec_helper'

describe 'Ol' do
  before :each do
    browser.goto(WatirSpec.url_for('non_control_elements.html'))
  end

  # Exists method
  describe '#exist?' do
    it "returns true if the 'ol' exists" do
      expect(browser.ol(id: 'favorite_compounds')).to exist
      expect(browser.ol(id: /favorite_compounds/)).to exist
      expect(browser.ol(index: 0)).to exist
      expect(browser.ol(xpath: "//ol[@id='favorite_compounds']")).to exist
    end

    it 'returns the first ol if given no args' do
      expect(browser.ol).to exist
    end

    it "returns false if the 'ol' doesn't exist" do
      expect(browser.ol(id: 'no_such_id')).to_not exist
      expect(browser.ol(id: /no_such_id/)).to_not exist
      expect(browser.ol(text: 'no_such_text')).to_not exist
      expect(browser.ol(text: /no_such_text/)).to_not exist
      expect(browser.ol(class: 'no_such_class')).to_not exist
      expect(browser.ol(class: /no_such_class/)).to_not exist
      expect(browser.ol(index: 1337)).to_not exist
      expect(browser.ol(xpath: "//ol[@id='no_such_id']")).to_not exist
    end

    it "returns false if the 'ol' doesn't exist" do
      expect(browser.ol(id: 'no_such_id')).to_not exist
      expect(browser.ol(id: /no_such_id/)).to_not exist
      expect(browser.ol(text: 'no_such_text')).to_not exist
      expect(browser.ol(text: /no_such_text/)).to_not exist
      expect(browser.ol(class: 'no_such_class')).to_not exist
      expect(browser.ol(class: /no_such_class/)).to_not exist
      expect(browser.ol(index: 1337)).to_not exist
      expect(browser.ol(xpath: "//ol[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.ol(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  # Attribute methods
  describe '#id' do
    it 'returns the id attribute' do
      expect(browser.ol(class: 'chemistry').id).to eq 'favorite_compounds'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.ol(index: 1).id).to eq ''
    end

    it "raises UnknownObjectException if the ol doesn't exist" do
      expect { browser.ol(id: 'no_such_id').id }.to raise_unknown_object_exception
      expect { browser.ol(index: 1337).id }.to raise_unknown_object_exception
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.ol(index: 0)).to respond_to(:class_name)
      expect(browser.ol(index: 0)).to respond_to(:id)
    end
  end
end
