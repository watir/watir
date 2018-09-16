require 'watirspec_helper'

describe 'Ul' do
  before :each do
    browser.goto(WatirSpec.url_for('non_control_elements.html'))
  end

  # Exists method
  describe '#exist?' do
    it "returns true if the 'ul' exists" do
      expect(browser.ul(id: 'navbar')).to exist
      expect(browser.ul(id: /navbar/)).to exist
      expect(browser.ul(index: 0)).to exist
      expect(browser.ul(xpath: "//ul[@id='navbar']")).to exist
    end

    it 'returns the first ul if given no args' do
      expect(browser.ul).to exist
    end

    it "returns false if the 'ul' doesn't exist" do
      expect(browser.ul(id: 'no_such_id')).to_not exist
      expect(browser.ul(id: /no_such_id/)).to_not exist
      expect(browser.ul(text: 'no_such_text')).to_not exist
      expect(browser.ul(text: /no_such_text/)).to_not exist
      expect(browser.ul(class: 'no_such_class')).to_not exist
      expect(browser.ul(class: /no_such_class/)).to_not exist
      expect(browser.ul(index: 1337)).to_not exist
      expect(browser.ul(xpath: "//ul[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.ul(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  # Attribute methods
  describe '#id' do
    it 'returns the id attribute' do
      expect(browser.ul(class: 'navigation').id).to eq 'navbar'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.ul(index: 1).id).to eq ''
    end

    it "raises UnknownObjectException if the ul doesn't exist" do
      expect { browser.ul(id: 'no_such_id').id }.to raise_unknown_object_exception
      expect { browser.ul(index: 1337).id }.to raise_unknown_object_exception
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.ul(index: 0)).to respond_to(:class_name)
      expect(browser.ul(index: 0)).to respond_to(:id)
    end
  end
end
