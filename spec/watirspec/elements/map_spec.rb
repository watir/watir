require 'watirspec_helper'

describe 'Map' do
  before :each do
    browser.goto(WatirSpec.url_for('images.html'))
  end

  # Exists method
  describe '#exist?' do
    it "returns true if the 'map' exists" do
      expect(browser.map(id: 'triangle_map')).to exist
      expect(browser.map(id: /triangle_map/)).to exist
      expect(browser.map(name: 'triangle_map')).to exist
      expect(browser.map(name: /triangle_map/)).to exist
      expect(browser.map(index: 0)).to exist
      expect(browser.map(xpath: "//map[@id='triangle_map']")).to exist
    end

    it 'returns the first map if given no args' do
      expect(browser.map).to exist
    end

    it "returns false if the 'map' doesn't exist" do
      expect(browser.map(id: 'no_such_id')).to_not exist
      expect(browser.map(id: /no_such_id/)).to_not exist
      expect(browser.map(name: 'no_such_id')).to_not exist
      expect(browser.map(name: /no_such_id/)).to_not exist
      expect(browser.map(index: 1337)).to_not exist
      expect(browser.map(xpath: "//map[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.map(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  # Attribute methods
  describe '#id' do
    it 'returns the id attribute' do
      expect(browser.map(index: 0).id).to eq 'triangle_map'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.map(index: 1).id).to eq ''
    end

    it "raises UnknownObjectException if the p doesn't exist" do
      expect { browser.map(id: 'no_such_id').id }.to raise_unknown_object_exception
      expect { browser.map(index: 1337).id }.to raise_unknown_object_exception
    end
  end

  describe '#name' do
    it 'returns the name attribute' do
      expect(browser.map(index: 0).name).to eq 'triangle_map'
    end

    it "returns an empty string if the element exists and the attribute doesn't" do
      expect(browser.map(index: 1).name).to eq ''
    end

    it "raises UnknownObjectException if the map doesn't exist" do
      expect { browser.map(id: 'no_such_id').name }.to raise_unknown_object_exception
      expect { browser.map(index: 1337).name }.to raise_unknown_object_exception
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.map(index: 0)).to respond_to(:id)
      expect(browser.map(index: 0)).to respond_to(:name)
    end
  end
end
