require 'watirspec_helper'

describe 'TableFooter' do
  before :each do
    browser.goto(WatirSpec.url_for('tables.html'))
  end

  describe '#exists?' do
    it 'returns true if the table tfoot exists (page context)' do
      expect(browser.tfoot(id: 'tax_totals')).to exist
      expect(browser.tfoot(id: /tax_totals/)).to exist
      expect(browser.tfoot(index: 0)).to exist
      expect(browser.tfoot(xpath: "//tfoot[@id='tax_totals']")).to exist
    end

    it 'returns true if the table tfoot exists (table context)' do
      expect(browser.table(index: 0).tfoot(id: 'tax_totals')).to exist
      expect(browser.table(index: 0).tfoot(id: /tax_totals/)).to exist
      expect(browser.table(index: 0).tfoot(index: 0)).to exist
      expect(browser.table(index: 0).tfoot(xpath: "//tfoot[@id='tax_totals']")).to exist
    end

    it 'returns the first tfoot if given no args' do
      expect(browser.tfoot).to exist
    end

    it "returns false if the table tfoot doesn't exist (page context)" do
      expect(browser.tfoot(id: 'no_such_id')).to_not exist
      expect(browser.tfoot(id: /no_such_id/)).to_not exist
      expect(browser.tfoot(index: 1337)).to_not exist
      expect(browser.tfoot(xpath: "//tfoot[@id='no_such_id']")).to_not exist
    end

    it "returns false if the table tfoot doesn't exist (table context)" do
      expect(browser.table(index: 0).tfoot(id: 'no_such_id')).to_not exist
      expect(browser.table(index: 0).tfoot(id: /no_such_id/)).to_not exist
      expect(browser.table(index: 0).tfoot(index: 1337)).to_not exist
      expect(browser.table(index: 0).tfoot(xpath: "//tfoot[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.tfoot(id: 3.14).exists? }.to raise_error(TypeError)
      expect { browser.table(index: 0).tfoot(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  describe '#[]' do
    it 'returns the row at the given index (page context)' do
      expect(browser.tfoot(id: 'tax_totals')[0].id).to eq 'tfoot_row_1'
      expect(browser.tfoot(id: 'tax_totals')[0][1].text).to eq '24 349'
      expect(browser.tfoot(id: 'tax_totals')[0][2].text).to eq '5 577'
    end

    it 'returns the row at the given index (table context)' do
      expect(browser.table(index: 0).tfoot(id: 'tax_totals')[0].id).to eq 'tfoot_row_1'
      expect(browser.table(index: 0).tfoot(id: 'tax_totals')[0][1].text).to eq '24 349'
      expect(browser.table(index: 0).tfoot(id: 'tax_totals')[0][2].text).to eq '5 577'
    end
  end

  describe '#row' do
    it 'finds the first row matching the selector' do
      row = browser.tfoot(id: 'tax_totals').row(id: 'tfoot_row_1')

      expect(row.id).to eq 'tfoot_row_1'
    end
  end

  describe '#rows' do
    it 'finds rows matching the selector' do
      rows = browser.tfoot(id: 'tax_totals').rows(id: 'tfoot_row_1')

      expect(rows.size).to eq 1
      expect(rows.first.id).to eq 'tfoot_row_1'
    end
  end

  describe '#strings' do
    it 'returns the text of child cells' do
      expect(browser.tfoot(id: 'tax_totals').strings).to eq [
        ['Sum', '24 349', '5 577', '18 722']
      ]
    end
  end
end
