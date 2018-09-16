require 'watirspec_helper'

describe 'P' do
  before :each do
    browser.goto(WatirSpec.url_for('non_control_elements.html'))
  end

  # Exists method
  describe '#exist?' do
    it "returns true if the 'p' exists" do
      expect(browser.p(id: 'lead')).to exist
      expect(browser.p(id: /lead/)).to exist
      expect(browser.p(text: 'Dubito, ergo cogito, ergo sum.')).to exist
      expect(browser.p(text: /Dubito, ergo cogito, ergo sum/)).to exist
      expect(browser.p(class: 'lead')).to exist
      expect(browser.p(class: /lead/)).to exist
      expect(browser.p(index: 0)).to exist
      expect(browser.p(xpath: "//p[@id='lead']")).to exist
    end

    it 'returns the first p if given no args' do
      expect(browser.p).to exist
    end

    it "returns false if the 'p' doesn't exist" do
      expect(browser.p(id: 'no_such_id')).to_not exist
      expect(browser.p(id: /no_such_id/)).to_not exist
      expect(browser.p(text: 'no_such_text')).to_not exist
      expect(browser.p(text: /no_such_text/)).to_not exist
      expect(browser.p(class: 'no_such_class')).to_not exist
      expect(browser.p(class: /no_such_class/)).to_not exist
      expect(browser.p(index: 1337)).to_not exist
      expect(browser.p(xpath: "//p[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.p(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  # Attribute methods
  describe '#id' do
    it 'returns the id attribute' do
      expect(browser.p(index: 0).id).to eq 'lead'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.p(index: 2).id).to eq ''
    end

    it "raises UnknownObjectException if the p doesn't exist" do
      expect { browser.p(id: 'no_such_id').id }.to raise_unknown_object_exception
      expect { browser.p(index: 1337).id }.to raise_unknown_object_exception
    end
  end

  describe '#title' do
    it 'returns the title attribute' do
      expect(browser.p(index: 0).title).to eq 'Lorem ipsum'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.p(index: 2).title).to eq ''
    end

    it "raises UnknownObjectException if the p doesn't exist" do
      expect { browser.p(id: 'no_such_id').title }.to raise_unknown_object_exception
      expect { browser.p(xpath: "//p[@id='no_such_id']").title }.to raise_unknown_object_exception
    end
  end

  describe '#text' do
    it 'returns the text of the p' do
      msg = 'Sed pretium metus et quam. Nullam odio dolor, vestibulum non, tempor ut, vehicula sed, sapien. ' \
            'Vestibulum placerat ligula at quam. Pellentesque habitant morbi tristique senectus et netus et ' \
            'malesuada fames ac turpis egestas.'
      expect(browser.p(index: 1).text).to eq msg
    end

    it "returns an empty string if the element doesn't contain any text" do
      expect(browser.p(index: 4).text).to eq ''
    end

    it "raises UnknownObjectException if the p doesn't exist" do
      expect { browser.p(id: 'no_such_id').text }.to raise_unknown_object_exception
      expect { browser.p(xpath: "//p[@id='no_such_id']").text }.to raise_unknown_object_exception
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.p(index: 0)).to respond_to(:class_name)
      expect(browser.p(index: 0)).to respond_to(:id)
      expect(browser.p(index: 0)).to respond_to(:title)
      expect(browser.p(index: 0)).to respond_to(:text)
    end
  end
end
