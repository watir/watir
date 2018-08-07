require 'watirspec_helper'

describe 'Label' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  # Exists method
  describe '#exists?' do
    it 'returns true if the element exists' do
      expect(browser.label(id: 'first_label')).to exist
      expect(browser.label(id: /first_label/)).to exist
      expect(browser.label(for: 'new_user_first_name')).to exist
      expect(browser.label(for: /new_user_first_name/)).to exist
      expect(browser.label(text: 'First name')).to exist
      expect(browser.label(text: /First name/)).to exist
      expect(browser.label(index: 0)).to exist
      expect(browser.label(xpath: "//label[@id='first_label']")).to exist
    end

    it 'returns the first label if given no args' do
      expect(browser.label).to exist
    end

    it 'returns false if the element does not exist' do
      expect(browser.label(id: 'no_such_id')).to_not exist
      expect(browser.label(id: /no_such_id/)).to_not exist
      expect(browser.label(text: 'no_such_text')).to_not exist
      expect(browser.label(text: /no_such_text/)).to_not exist
      expect(browser.label(index: 1337)).to_not exist
      expect(browser.label(xpath: "//input[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.label(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  describe 'click' do
    it 'fires the onclick event' do
      browser.label(id: 'first_label').click
      expect(messages.first).to eq 'label'
    end
  end

  # Attribute methods
  describe '#id' do
    it 'returns the id attribute if the label exists' do
      expect(browser.label(index: 0).id).to eq 'first_label'
    end

    it "raises UnknownObjectException if the label doesn't exist" do
      expect { browser.label(index: 1337).id }.to raise_unknown_object_exception
    end
  end

  describe '#for' do
    it "returns the 'for' attribute if the label exists" do
      expect(browser.label(index: 0).for).to eq 'new_user_first_name'
    end

    it "raises UnknownObjectException if the label doesn't exist" do
      expect { browser.label(index: 1337).for }.to raise_unknown_object_exception
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.label(index: 0)).to respond_to(:id)
      expect(browser.label(index: 0)).to respond_to(:for)
    end
  end
end
