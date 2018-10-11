require 'watirspec_helper'

describe 'Links' do
  before :each do
    browser.goto(WatirSpec.url_for('non_control_elements.html'))
  end

  describe 'with selectors' do
    it 'returns the matching elements' do
      expect(browser.links(title: 'link_title_2').to_a).to eq [browser.link(title: 'link_title_2')]
    end
  end

  describe '#length' do
    it 'returns the number of links' do
      expect(browser.links.length).to eq 7
    end
  end

  describe '#[]' do
    it 'returns the link at the given index' do
      expect(browser.links[2].id).to eq 'link_3'
    end

    it 'returns a Link object also when the index is out of bounds' do
      expect(browser.links[2000]).to_not be_nil
    end
  end

  describe '#each' do
    it 'iterates through links correctly' do
      count = 0

      browser.links.each_with_index do |c, index|
        expect(c.id).to eq browser.link(index: index).id
        count += 1
      end

      expect(count).to be > 0
    end
  end

  describe 'visible text' do
    it 'finds links by visible text' do
      browser.goto WatirSpec.url_for('non_control_elements.html')
      container = browser.div(id: 'visible_text')
      expect(container.links(visible_text: 'all visible').count).to eq(1)
      expect(container.links(visible_text: /all visible/).count).to eq(1)
      expect(container.links(visible_text: 'some visible').count).to eq(1)
      expect(container.links(visible_text: /some visible/).count).to eq(1)
      expect(container.links(visible_text: 'none visible').count).to eq(0)
      expect(container.links(visible_text: /none visible/).count).to eq(0)
    end
  end
end
