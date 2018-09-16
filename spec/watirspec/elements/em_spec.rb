require 'watirspec_helper'

describe 'Em' do
  before :each do
    browser.goto(WatirSpec.url_for('non_control_elements.html'))
  end

  # Exists method
  describe '#exists?' do
    it 'returns true if the element exists' do
      expect(browser.em(id: 'important-id')).to exist
      expect(browser.em(class: 'important-class')).to exist
      expect(browser.em(xpath: "//em[@id='important-id']")).to exist
      expect(browser.em(index: 0)).to exist
    end

    it 'returns the first em if given no args' do
      expect(browser.em).to exist
    end

    it 'returns false if the element does not exist' do
      expect(browser.em(id: 'no_such_id')).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.em(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  # Attribute methods
  describe '#id' do
    it 'returns the id attribute if the element exists' do
      expect(browser.em(class: 'important-class').id).to eq 'important-id'
    end

    it 'raises UnknownObjectException if the element does not exist' do
      expect { browser.em(id: 'no_such_id').id }.to raise_unknown_object_exception
      expect { browser.em(title: 'no_such_id').id }.to raise_unknown_object_exception
      expect { browser.em(index: 1337).id }.to raise_unknown_object_exception
    end
  end

  describe '#title' do
    it 'returns the title of the element' do
      expect(browser.em(class: 'important-class').title).to eq 'ergo cogito'
    end
  end

  describe '#text' do
    it 'returns the text of the element' do
      expect(browser.em(id: 'important-id').text).to eq 'ergo cogito'
    end

    it 'raises UnknownObjectException if the element does not exist' do
      expect { browser.em(id: 'no_such_id').text }.to raise_unknown_object_exception
      expect { browser.em(title: 'no_such_title').text }.to raise_unknown_object_exception
      expect { browser.em(index: 1337).text }.to raise_unknown_object_exception
      expect { browser.em(xpath: "//em[@id='no_such_id']").text }.to raise_unknown_object_exception
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.em(index: 0)).to respond_to(:id)
      expect(browser.em(index: 0)).to respond_to(:class_name)
      expect(browser.em(index: 0)).to respond_to(:style)
      expect(browser.em(index: 0)).to respond_to(:text)
      expect(browser.em(index: 0)).to respond_to(:title)
    end
  end

  # Manipulation methods
  describe '#click' do
    it 'raises UnknownObjectException if the element does not exist' do
      expect { browser.em(id: 'no_such_id').click }.to raise_unknown_object_exception
      expect { browser.em(title: 'no_such_title').click }.to raise_unknown_object_exception
      expect { browser.em(index: 1337).click }.to raise_unknown_object_exception
      expect { browser.em(xpath: "//em[@id='no_such_id']").click }.to raise_unknown_object_exception
    end
  end
end
