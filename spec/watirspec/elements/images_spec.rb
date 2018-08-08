require 'watirspec_helper'

describe 'Images' do
  before :each do
    browser.goto(WatirSpec.url_for('images.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.images(alt: 'circle').to_a).to eq [browser.image(alt: 'circle')]
    end
  end

  describe '#length' do
    it 'returns the number of images' do
      expect(browser.images.length).to eq 10
    end
  end

  describe '#[]' do
    it 'returns the image at the given index' do
      expect(browser.images[5].id).to eq 'square'
    end
  end

  describe '#each' do
    it 'iterates through images correctly' do
      count = 0

      browser.images.each_with_index do |c, index|
        expect(c.id).to eq browser.image(index: index).id
        count += 1
      end

      expect(count).to be > 0
    end
  end
end
