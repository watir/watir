require 'watirspec_helper'

describe 'Li' do
  before :each do
    browser.goto(WatirSpec.url_for('non_control_elements.html'))
  end

  # Exists method
  describe '#exist?' do
    it "returns true if the 'li' exists" do
      expect(browser.li(id: 'non_link_1')).to exist
      expect(browser.li(id: /non_link_1/)).to exist
      expect(browser.li(text: 'Non-link 3')).to exist
      expect(browser.li(text: /Non-link 3/)).to exist
      expect(browser.li(class: 'nonlink')).to exist
      expect(browser.li(class: /nonlink/)).to exist
      expect(browser.li(index: 0)).to exist
      expect(browser.li(xpath: "//li[@id='non_link_1']")).to exist
    end

    it 'returns the first element if given no args' do
      expect(browser.li).to exist
    end

    it "returns false if the 'li' doesn't exist" do
      expect(browser.li(id: 'no_such_id')).to_not exist
      expect(browser.li(id: /no_such_id/)).to_not exist
      expect(browser.li(text: 'no_such_text')).to_not exist
      expect(browser.li(text: /no_such_text/)).to_not exist
      expect(browser.li(class: 'no_such_class')).to_not exist
      expect(browser.li(class: /no_such_class/)).to_not exist
      expect(browser.li(index: 1337)).to_not exist
      expect(browser.li(xpath: "//li[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.li(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  # Attribute methods
  describe '#id' do
    it 'returns the id attribute' do
      expect(browser.li(class: 'nonlink').id).to eq 'non_link_1'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.li(index: 0).id).to eq ''
    end

    it "raises UnknownObjectException if the li doesn't exist" do
      expect { browser.li(id: 'no_such_id').id }.to raise_unknown_object_exception
      expect { browser.li(index: 1337).id }.to raise_unknown_object_exception
    end
  end

  describe '#title' do
    it 'returns the title attribute' do
      expect(browser.li(id: 'non_link_1').title).to eq 'This is not a link!'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.li(index: 0).title).to eq ''
    end

    it "raises UnknownObjectException if the li doesn't exist" do
      expect { browser.li(id: 'no_such_id').title }.to raise_unknown_object_exception
      expect { browser.li(xpath: "//li[@id='no_such_id']").title }.to raise_unknown_object_exception
    end
  end

  describe '#text' do
    it 'returns the text of the li' do
      expect(browser.li(id: 'non_link_1').text).to eq 'Non-link 1'
    end

    it "returns an empty string if the element doesn't contain any text" do
      expect(browser.li(index: 0).text).to eq ''
    end

    it "raises UnknownObjectException if the li doesn't exist" do
      expect { browser.li(id: 'no_such_id').text }.to raise_unknown_object_exception
      expect { browser.li(xpath: "//li[@id='no_such_id']").text }.to raise_unknown_object_exception
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.li(index: 0)).to respond_to(:class_name)
      expect(browser.li(index: 0)).to respond_to(:id)
      expect(browser.li(index: 0)).to respond_to(:text)
      expect(browser.li(index: 0)).to respond_to(:title)
    end
  end
end
