require 'watirspec_helper'

describe 'Area' do
  before :each do
    browser.goto(WatirSpec.url_for('images.html'))
  end

  # Exists method
  describe '#exist?' do
    it 'returns true if the area exists' do
      expect(browser.area(id: 'NCE')).to exist
      expect(browser.area(id: /NCE/)).to exist
      expect(browser.area(title: 'Tables')).to exist
      expect(browser.area(title: /Tables/)).to exist

      not_compliant_on :internet_explorer do
        expect(browser.area(href: 'tables.html')).to exist
      end

      expect(browser.area(href: /tables/)).to exist

      expect(browser.area(index: 0)).to exist
      expect(browser.area(xpath: "//area[@id='NCE']")).to exist
    end

    it 'returns the first area if given no args' do
      expect(browser.area).to exist
    end

    it "returns false if the area doesn't exist" do
      expect(browser.area(id: 'no_such_id')).to_not exist
      expect(browser.area(id: /no_such_id/)).to_not exist
      expect(browser.area(title: 'no_such_title')).to_not exist
      expect(browser.area(title: /no_such_title/)).to_not exist

      expect(browser.area(href: 'no-tables.html')).to_not exist
      expect(browser.area(href: /no-tables/)).to_not exist

      expect(browser.area(index: 1337)).to_not exist
      expect(browser.area(xpath: "//area[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.area(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  # Attribute methods
  describe '#id' do
    it 'returns the id attribute' do
      expect(browser.area(index: 0).id).to eq 'NCE'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.area(index: 2).id).to eq ''
    end

    it "raises UnknownObjectException if the area doesn't exist" do
      expect { browser.area(id: 'no_such_id').id }.to raise_unknown_object_exception
      expect { browser.area(index: 1337).id }.to raise_unknown_object_exception
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.area(index: 0)).to respond_to(:id)
    end
  end
end
