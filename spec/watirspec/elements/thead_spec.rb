require 'watirspec_helper'

describe 'TableHeader' do
  before :each do
    browser.goto(WatirSpec.url_for('tables.html'))
  end

  describe '#exists?' do
    it 'returns true if the table theader exists (page context)' do
      expect(browser.thead(id: 'tax_headers')).to exist
      expect(browser.thead(id: /tax_headers/)).to exist
      expect(browser.thead(index: 0)).to exist
      expect(browser.thead(xpath: "//thead[@id='tax_headers']")).to exist
    end

    it 'returns the first thead if given no args' do
      expect(browser.thead).to exist
    end

    it 'returns true if the table theader exists (table context)' do
      expect(browser.table(index: 0).thead(id: 'tax_headers')).to exist
      expect(browser.table(index: 0).thead(id: /tax_headers/)).to exist
      expect(browser.table(index: 0).thead(index: 0)).to exist
      expect(browser.table(index: 0).thead(xpath: "//thead[@id='tax_headers']")).to exist
    end

    it "returns false if the table theader doesn't exist (page context)" do
      expect(browser.thead(id: 'no_such_id')).to_not exist
      expect(browser.thead(id: /no_such_id/)).to_not exist
      expect(browser.thead(index: 1337)).to_not exist
      expect(browser.thead(xpath: "//thead[@id='no_such_id']")).to_not exist
    end

    it "returns false if the table theader doesn't exist (table context)" do
      expect(browser.table(index: 0).thead(id: 'no_such_id')).to_not exist
      expect(browser.table(index: 0).thead(id: /no_such_id/)).to_not exist
      expect(browser.table(index: 0).thead(index: 1337)).to_not exist
      expect(browser.table(index: 0).thead(xpath: "//thead[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.thead(id: 3.14).exists? }.to raise_error(TypeError)
      expect { browser.table(index: 0).thead(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  describe '#[]' do
    it 'returns the row at the given index (page context)' do
      expect(browser.thead(id: 'tax_headers')[0].id).to eq 'thead_row_1'
      expect(browser.thead(id: 'tax_headers')[0][1].text).to eq 'Before income tax'
      expect(browser.thead(id: 'tax_headers')[0][2].text).to eq 'Income tax'
    end

    it 'returns the row at the given index (table context)' do
      expect(browser.table(index: 0).thead(id: 'tax_headers')[0].id).to eq 'thead_row_1'
      expect(browser.table(index: 0).thead(id: 'tax_headers')[0][1].text).to eq 'Before income tax'
      expect(browser.table(index: 0).thead(id: 'tax_headers')[0][2].text).to eq 'Income tax'
    end
  end

  describe '#row' do
    it 'finds the first row matching the selector' do
      row = browser.thead(id: 'tax_headers').row(class: 'dark')
      expect(row.id).to eq 'thead_row_1'
    end
  end

  describe '#rows' do
    it 'finds rows matching the selector' do
      rows = browser.thead(id: 'tax_headers').rows(class: 'dark')

      expect(rows.size).to eq 1
      expect(rows.first.id).to eq 'thead_row_1'
    end
  end

  describe '#strings' do
    it 'returns the text of child cells' do
      expect(browser.thead(id: 'tax_headers').strings).to eq [
        ['', 'Before income tax', 'Income tax', 'After income tax']
      ]
    end
  end
end
