require 'watirspec_helper'

describe 'TableBody' do
  before :each do
    browser.goto(WatirSpec.url_for('tables.html'))
  end

  describe '#exists?' do
    it 'returns true if the table body exists (page context)' do
      expect(browser.tbody(id: 'first')).to exist
      expect(browser.tbody(id: /first/)).to exist
      expect(browser.tbody(index: 0)).to exist
      expect(browser.tbody(xpath: "//tbody[@id='first']")).to exist
    end

    it 'returns true if the table body exists (table context)' do
      expect(browser.table(index: 0).tbody(id: 'first')).to exist
      expect(browser.table(index: 0).tbody(id: /first/)).to exist
      expect(browser.table(index: 0).tbody(index: 1)).to exist
      expect(browser.table(index: 0).tbody(xpath: "//tbody[@id='first']")).to exist
    end

    it 'returns the first table body if given no args' do
      expect(browser.table.tbody).to exist
    end

    it "returns false if the table body doesn't exist (page context)" do
      expect(browser.tbody(id: 'no_such_id')).to_not exist
      expect(browser.tbody(id: /no_such_id/)).to_not exist
      expect(browser.tbody(index: 1337)).to_not exist
      expect(browser.tbody(xpath: "//tbody[@id='no_such_id']")).to_not exist
    end

    it "returns false if the table body doesn't exist (table context)" do
      expect(browser.table(index: 0).tbody(id: 'no_such_id')).to_not exist
      expect(browser.table(index: 0).tbody(id: /no_such_id/)).to_not exist
      expect(browser.table(index: 0).tbody(index: 1337)).to_not exist
      expect(browser.table(index: 0).tbody(xpath: "//tbody[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.tbody(id: 3.14).exists? }.to raise_error(TypeError)
      expect { browser.table(index: 0).tbody(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  bug 'Safari does not strip text', :safari do
    describe '#[]' do
      it 'returns the row at the given index (page context)' do
        expect(browser.tbody(id: 'first')[0].text).to eq 'March 2008'
        expect(browser.tbody(id: 'first')[1][0].text).to eq 'Gregory House'
        expect(browser.tbody(id: 'first')[2][0].text).to eq 'Hugh Laurie'
      end

      it 'returns the row at the given index (table context)' do
        expect(browser.table(index: 0).tbody(id: 'first')[0].text).to eq 'March 2008'
        expect(browser.table(index: 0).tbody(id: 'first')[1][0].text).to eq 'Gregory House'
        expect(browser.table(index: 0).tbody(id: 'first')[2][0].text).to eq 'Hugh Laurie'
      end
    end
  end

  describe '#row' do
    it 'finds the first row matching the selector' do
      row = browser.tbody(id: 'first').row(id: 'gregory')

      expect(row.tag_name).to eq 'tr'
      expect(row.id).to eq 'gregory'
    end
  end

  describe '#rows' do
    it 'finds rows matching the selector' do
      rows = browser.tbody(id: 'first').rows(id: /h$/)

      expect(rows.size).to eq 2

      expect(rows.first.id).to eq 'march'
      expect(rows.last.id).to eq 'hugh'
    end
  end

  describe '#strings' do
    it 'returns the text of child cells' do
      expect(browser.tbody(id: 'first').strings).to eq [
        ['March 2008', '', '', ''],
        ['Gregory House', '5 934', '1 347', '4 587'],
        ['Hugh Laurie', '6 300', '1 479', '4 821']
      ]
    end
  end
end
