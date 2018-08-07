require 'watirspec_helper'

describe 'Hidden' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  # Exist method
  describe '#exists?' do
    it 'returns true if the element exists' do
      expect(browser.hidden(id: 'new_user_interests_dolls')).to exist
      expect(browser.hidden(id: /new_user_interests_dolls/)).to exist
      expect(browser.hidden(name: 'new_user_interests')).to exist
      expect(browser.hidden(name: /new_user_interests/)).to exist
      expect(browser.hidden(value: 'dolls')).to exist
      expect(browser.hidden(value: /dolls/)).to exist
      expect(browser.hidden(class: 'fun')).to exist
      expect(browser.hidden(class: /fun/)).to exist
      expect(browser.hidden(index: 0)).to exist
      expect(browser.hidden(xpath: "//input[@id='new_user_interests_dolls']")).to exist
    end

    it 'returns the first hidden if given no args' do
      expect(browser.hidden).to exist
    end

    it 'returns false if the element does not exist' do
      expect(browser.hidden(id: 'no_such_id')).to_not exist
      expect(browser.hidden(id: /no_such_id/)).to_not exist
      expect(browser.hidden(name: 'no_such_name')).to_not exist
      expect(browser.hidden(name: /no_such_name/)).to_not exist
      expect(browser.hidden(value: 'no_such_value')).to_not exist
      expect(browser.hidden(value: /no_such_value/)).to_not exist
      expect(browser.hidden(text: 'no_such_text')).to_not exist
      expect(browser.hidden(text: /no_such_text/)).to_not exist
      expect(browser.hidden(class: 'no_such_class')).to_not exist
      expect(browser.hidden(class: /no_such_class/)).to_not exist
      expect(browser.hidden(index: 1337)).to_not exist
      expect(browser.hidden(xpath: "//input[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.hidden(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  # Attribute methods
  describe '#id' do
    it 'returns the id attribute if the text field exists' do
      expect(browser.hidden(index: 1).id).to eq 'new_user_interests_dolls'
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.hidden(index: 1337).id }.to raise_unknown_object_exception
    end
  end

  describe '#name' do
    it 'returns the name attribute if the text field exists' do
      expect(browser.hidden(index: 1).name).to eq 'new_user_interests'
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.hidden(index: 1337).name }.to raise_unknown_object_exception
    end
  end

  describe '#type' do
    it 'returns the type attribute if the text field exists' do
      expect(browser.hidden(index: 1).type).to eq 'hidden'
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.hidden(index: 1337).type }.to raise_unknown_object_exception
    end
  end

  describe '#value' do
    it 'returns the value attribute if the text field exists' do
      expect(browser.hidden(index: 1).value).to eq 'dolls'
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.hidden(index: 1337).value }.to raise_unknown_object_exception
    end
  end

  describe '#click' do
    it 'raises ObjectDisabledException when attempting to click' do
      expect { browser.hidden(index: 1337).click }.to raise_object_disabled_exception
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.hidden(index: 1)).to respond_to(:id)
      expect(browser.hidden(index: 1)).to respond_to(:name)
      expect(browser.hidden(index: 1)).to respond_to(:type)
      expect(browser.hidden(index: 1)).to respond_to(:value)
    end
  end
end
