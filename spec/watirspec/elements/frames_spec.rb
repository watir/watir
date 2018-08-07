require 'watirspec_helper'

describe 'Frames' do
  before :each do
    browser.goto(WatirSpec.url_for('frames.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.frames(name: 'frame2').to_a).to eq [browser.frame(name: 'frame2')]
    end
  end

  describe '#length' do
    it 'returns the correct number of frames' do
      expect(browser.frames.length).to eq 2
    end
  end

  describe '#[]' do
    it 'returns the frame at the given index' do
      expect(browser.frames[0].id).to eq 'frame_1'
    end
  end

  describe '#each' do
    it 'iterates through frames correctly' do
      count = 0

      browser.frames.each_with_index do |f, index|
        expect(f.name).to eq browser.frame(index: index).name
        expect(f.id).to eq browser.frame(index: index).id
        count += 1
      end

      expect(count).to be > 0
    end
  end
end
