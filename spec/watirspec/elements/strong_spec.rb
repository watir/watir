require 'watirspec_helper'

describe 'Strong' do
  before :each do
    browser.goto(WatirSpec.url_for('non_control_elements.html'))
  end

  # Exists method
  describe '#exist?' do
    it 'returns true if the element exists' do
      expect(browser.strong(id: 'descartes')).to exist
      expect(browser.strong(id: /descartes/)).to exist
      expect(browser.strong(text: 'Dubito, ergo cogito, ergo sum.')).to exist
      expect(browser.strong(class: 'descartes')).to exist
      expect(browser.strong(class: /descartes/)).to exist
      expect(browser.strong(index: 0)).to exist
      expect(browser.strong(xpath: "//strong[@id='descartes']")).to exist
    end

    it 'visible text is found by regular expression with text locator' do
      expect(browser.strong(text: /Dubito, ergo cogito, ergo sum/)).to exist
    end

    it 'returns the first strong if given no args' do
      expect(browser.strong).to exist
    end

    it "returns false if the element doesn't exist" do
      expect(browser.strong(id: 'no_such_id')).to_not exist
      expect(browser.strong(id: /no_such_id/)).to_not exist
      expect(browser.strong(text: 'no_such_text')).to_not exist
      expect(browser.strong(text: /no_such_text/)).to_not exist
      expect(browser.strong(class: 'no_such_class')).to_not exist
      expect(browser.strong(class: /no_such_class/)).to_not exist
      expect(browser.strong(index: 1337)).to_not exist
      expect(browser.strong(xpath: "//strong[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.strong(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  # Attribute methods
  describe '#id' do
    it 'returns the id attribute' do
      expect(browser.strong(index: 0).id).to eq 'descartes'
    end

    it "raises UnknownObjectException if the element doesn't exist" do
      expect { browser.strong(id: 'no_such_id').id }.to raise_unknown_object_exception
      expect { browser.strong(index: 1337).id }.to raise_unknown_object_exception
    end
  end

  describe '#text' do
    it 'returns the text of the element' do
      expect(browser.strong(index: 0).text).to eq 'Dubito, ergo cogito, ergo sum.'
    end

    it "raises UnknownObjectException if the element doesn't exist" do
      expect { browser.strong(id: 'no_such_id').text }.to raise_unknown_object_exception
      expect { browser.strong(xpath: "//strong[@id='no_such_id']").text }.to raise_unknown_object_exception
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.strong(index: 0)).to respond_to(:class_name)
      expect(browser.strong(index: 0)).to respond_to(:id)
      expect(browser.strong(index: 0)).to respond_to(:text)
    end
  end

  # Other
end
