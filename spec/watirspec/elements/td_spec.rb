require 'watirspec_helper'

describe 'TableCell' do
  before :each do
    browser.goto(WatirSpec.url_for('tables.html'))
  end

  # Exists
  describe '#exists?' do
    it 'returns true when the table cell exists' do
      expect(browser.td(id: 't1_r2_c1')).to exist
      expect(browser.td(id: /t1_r2_c1/)).to exist
      expect(browser.td(text: 'Table 1, Row 3, Cell 1')).to exist
      expect(browser.td(text: /Table 1/)).to exist
      expect(browser.td(index: 0)).to exist
      expect(browser.td(xpath: "//td[@id='t1_r2_c1']")).to exist
    end

    it 'returns the first cell if given no args' do
      expect(browser.td).to exist
    end

    it 'returns false when the table cell does not exist' do
      expect(browser.td(id: 'no_such_id')).to_not exist
      expect(browser.td(id: /no_such_id/)).to_not exist
      expect(browser.td(text: 'no_such_text')).to_not exist
      expect(browser.td(text: /no_such_text/)).to_not exist
      expect(browser.td(index: 1337)).to_not exist
      expect(browser.td(xpath: "//td[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.td(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  describe '#click' do
    it "fires the table's onclick event" do
      browser.td(id: 't2_r1_c1').click
      expect(messages).to include('td')
    end
  end

  # Attribute methods
  bug 'Safari does not strip text', :safari do
    describe '#text' do
      it 'returns the text inside the table cell' do
        expect(browser.td(id: 't1_r2_c1').text).to eq 'Table 1, Row 2, Cell 1'
        expect(browser.td(id: 't2_r1_c1').text).to eq 'Table 2, Row 1, Cell 1'
      end
    end
  end

  describe '#colspan' do
    it 'gets the colspan attribute' do
      expect(browser.td(id: 'colspan_2').colspan).to eq 2
      expect(browser.td(id: 'no_colspan').colspan).to eq 1
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.td(index: 0)).to respond_to(:text)
      expect(browser.td(index: 0)).to respond_to(:colspan)
    end
  end

  describe '#column_header' do
    it 'returns the corresponding column header' do
      header = browser.td(text: '1 331').column_header
      expect(header).to eq 'Income tax'
    end
  end

  describe '#sibling_from_header' do
    it 'returns the corresponding sibling cell by text' do
      local_td = browser.td(text: '1 331')

      td = local_td.sibling_from_header(text: 'After income tax')
      expect(td.text).to eq '4 532'
    end

    it 'returns the corresponding sibling cell by index' do
      local_td = browser.td(text: '1 331')

      td = local_td.sibling_from_header(text: /tax/, index: 2)
      expect(td.text).to eq '4 532'
    end
  end
end
