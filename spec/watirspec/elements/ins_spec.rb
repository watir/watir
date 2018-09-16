require 'watirspec_helper'

describe 'Ins' do
  before :each do
    browser.goto(WatirSpec.url_for('non_control_elements.html'))
  end

  # Exists method
  describe '#exist?' do
    it "returns true if the 'ins' exists" do
      expect(browser.ins(id: 'lead')).to exist
      expect(browser.ins(id: /lead/)).to exist
      expect(browser.ins(text: 'This is an inserted text tag 1')).to exist
      expect(browser.ins(text: /This is an inserted text tag 1/)).to exist
      expect(browser.ins(class: 'lead')).to exist
      expect(browser.ins(class: /lead/)).to exist
      expect(browser.ins(index: 0)).to exist
      expect(browser.ins(xpath: "//ins[@id='lead']")).to exist
    end

    it 'returns the first ins if given no args' do
      expect(browser.ins).to exist
    end

    it "returns false if the element doesn't exist" do
      expect(browser.ins(id: 'no_such_id')).to_not exist
      expect(browser.ins(id: /no_such_id/)).to_not exist
      expect(browser.ins(text: 'no_such_text')).to_not exist
      expect(browser.ins(text: /no_such_text/)).to_not exist
      expect(browser.ins(class: 'no_such_class')).to_not exist
      expect(browser.ins(class: /no_such_class/)).to_not exist
      expect(browser.ins(index: 1337)).to_not exist
      expect(browser.ins(xpath: "//ins[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.ins(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  # Attribute methods
  describe '#id' do
    it 'returns the id attribute' do
      expect(browser.ins(index: 0).id).to eq 'lead'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.ins(index: 2).id).to eq ''
    end

    it "raises UnknownObjectException if the ins doesn't exist" do
      expect { browser.ins(id: 'no_such_id').id }.to raise_unknown_object_exception
      expect { browser.ins(index: 1337).id }.to raise_unknown_object_exception
    end
  end

  describe '#title' do
    it 'returns the title attribute' do
      expect(browser.ins(index: 0).title).to eq 'Lorem ipsum'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.ins(index: 2).title).to eq ''
    end

    it "raises UnknownObjectException if the ins doesn't exist" do
      expect { browser.ins(id: 'no_such_id').title }.to raise_unknown_object_exception
      expect { browser.ins(xpath: "//ins[@id='no_such_id']").title }.to raise_unknown_object_exception
    end
  end

  describe '#text' do
    it 'returns the text of the ins' do
      expect(browser.ins(index: 1).text).to eq 'This is an inserted text tag 2'
    end

    it "returns an empty string if the element doesn't contain any text" do
      expect(browser.ins(index: 3).text).to eq ''
    end

    it "raises UnknownObjectException if the ins doesn't exist" do
      expect { browser.ins(id: 'no_such_id').text }.to raise_unknown_object_exception
      expect { browser.ins(xpath: "//ins[@id='no_such_id']").text }.to raise_unknown_object_exception
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.ins(index: 0)).to respond_to(:class_name)
      expect(browser.ins(index: 0)).to respond_to(:id)
      expect(browser.ins(index: 0)).to respond_to(:title)
      expect(browser.ins(index: 0)).to respond_to(:text)
    end
  end

  # Other
  not_compliant_on :headless do
    describe '#click' do
      it 'fires events' do
        expect(browser.ins(class: 'footer').text).to_not include('Javascript')
        browser.ins(class: 'footer').click
        expect(browser.ins(class: 'footer').text).to include('Javascript')
      end

      it "raises UnknownObjectException if the ins doesn't exist" do
        expect { browser.ins(id: 'no_such_id').click }.to raise_unknown_object_exception
        expect { browser.ins(title: 'no_such_title').click }.to raise_unknown_object_exception
      end
    end
  end
end
