# frozen_string_literal: true

require 'watirspec_helper'

module Watir
  describe Table do
    before do
      browser.goto(WatirSpec.url_for('tables.html'))
    end

    # Exists
    describe '#exists?' do
      it 'returns true if the table exists' do
        expect(browser.table(id: 'axis_example')).to exist
        expect(browser.table(id: /axis_example/)).to exist
        expect(browser.table(index: 0)).to exist
        expect(browser.table(xpath: "//table[@id='axis_example']")).to exist
      end

      it 'returns the first table if given no args' do
        expect(browser.table).to exist
      end

      it 'returns false if the table does not exist' do
        expect(browser.table(id: 'no_such_id')).not_to exist
        expect(browser.table(id: /no_such_id/)).not_to exist
        expect(browser.table(index: 1337)).not_to exist
        expect(browser.table(xpath: "//table[@id='no_such_id']")).not_to exist
      end

      it 'checks the tag name when locating by xpath' do
        expect(browser.table(xpath: '//table//td')).not_to exist
        expect(browser.table(xpath: '//table')).to exist
      end

      it "raises TypeError when 'what' argument is invalid" do
        expect { browser.table(id: 3.14).exists? }.to raise_error(TypeError)
      end
    end

    # Other
    describe '#strings', except: {browser: :safari, reason: 'Safari does not strip text'} do
      it 'returns a two-dimensional array representation of the table' do
        expect(browser.table(id: 'inner').strings).to eq [
          ['Table 2, Row 1, Cell 1',
           'Table 2, Row 1, Cell 2']
        ]
        expect(browser.table(id: 'outer').strings).to eq [
          ['Table 1, Row 1, Cell 1', 'Table 1, Row 1, Cell 2'],
          ['Table 1, Row 2, Cell 1',
           "Table 1, Row 2, Cell 2\nTable 2, Row 1, Cell 1 Table 2, Row 1, Cell 2"],
          ['Table 1, Row 3, Cell 1', 'Table 1, Row 3, Cell 2']
        ]
      end
    end

    describe '#headers' do
      it 'returns the first row of a table as the header row' do
        headers = browser.table(id: 'axis_example').headers
        expect(headers).to be_a Watir::TableHeaderCellCollection
        expect(headers.size).to eq 4
      end
    end

    describe '#hashes' do
      it 'returns an Array of Hashes for the common table usage' do
        array = [
          {'' => 'March 2008', 'Before income tax' => '', 'Income tax' => '', 'After income tax' => ''},
          {'' => 'Gregory House', 'Before income tax' => '5 934', 'Income tax' => '1 347',
           'After income tax' => '4 587'},
          {'' => 'Hugh Laurie', 'Before income tax' => '6 300', 'Income tax' => '1 479', 'After income tax' => '4 821'},
          {'' => 'April 2008', 'Before income tax' => '', 'Income tax' => '', 'After income tax' => ''},
          {'' => 'Gregory House', 'Before income tax' => '5 863', 'Income tax' => '1 331',
           'After income tax' => '4 532'},
          {'' => 'Hugh Laurie', 'Before income tax' => '6 252', 'Income tax' => '1 420', 'After income tax' => '4 832'},
          {'' => 'Sum', 'Before income tax' => '24 349', 'Income tax' => '5 577', 'After income tax' => '18 722'}
        ]
        expect(browser.table(id: 'axis_example').hashes).to eq array
      end

      it 'raises an error if the table could not be parsed' do
        browser.goto(WatirSpec.url_for('uneven_table.html'))

        expect {
          browser.table.hashes
        }.to raise_error('row at index 0 has 2 cells, while header row has 3')
      end
    end

    describe '#click' do
      it "fires the table's onclick event" do
        browser.table(id: 'inner').click
        expect(messages).to include('table')
      end
    end

    describe '#[]' do
      it 'returns the nth child row' do
        expect(browser.table(id: 'outer')[0].id).to eq 'outer_first'
        expect(browser.table(id: 'inner')[0].id).to eq 'inner_first'
        expect(browser.table(id: 'outer')[2].id).to eq 'outer_last'
      end
    end

    describe '#row' do
      let(:table) { browser.table(id: 'outer') }

      it 'finds rows belonging to this table' do
        expect(table.row(id: 'outer_last')).to exist
        expect(table.row(text: /Table 1, Row 1, Cell 1/)).to exist
      end

      it 'does not find rows from a nested table' do
        expect(table.row(id: 'inner_first')).not_to exist
        expect(table.row(text: /\ATable 2, Row 1, Cell 1 Table 2, Row 1, Cell 2\z/)).not_to exist
      end
    end

    describe '#rows' do
      it 'finds the correct number of rows (excluding nested tables)' do
        expect(browser.table(id: 'inner').rows.length).to eq 1
        expect(browser.table(id: 'outer').rows.length).to eq 3
      end

      it 'finds rows matching the selector' do
        rows = browser.table(id: 'outer').rows(id: /first|last/)

        expect(rows.first.id).to eq 'outer_first'
        expect(rows.last.id).to eq 'outer_last'
      end

      it 'does not find rows from a nested table' do
        expect(browser.table(id: 'outer').rows(id: 't2_r1_c1').size).to eq 0
      end
    end

    describe '#tbody' do
      it 'returns the correct instance of TableSection' do
        body = browser.table(index: 0).tbody(id: 'first')
        expect(body).to be_instance_of(Watir::TableSection)
        expect(body[0][0].text).to eq 'March 2008'
      end
    end

    describe '#tbodys' do
      it 'returns the correct instance of TableSection' do
        bodies = browser.table(index: 0).tbodys

        expect(bodies).to be_instance_of(Watir::TableSectionCollection)

        expect(bodies[0].id).to eq 'first'
        expect(bodies[1].id).to eq 'second'
      end
    end

    describe '#each' do
      it 'allows iterating over the rows in a table' do
        expect(browser.table(id: 'inner').to_a).to all be_a Watir::Row
      end
    end

    context 'when nested' do
      before do
        browser.goto(WatirSpec.url_for('nested_tables.html'))
      end

      it 'returns the correct number of rows under a table element' do
        tables = browser.div(id: 'table-rows-test').tables(id: /^tbl/)
        expect(tables.length).to be > 0

        tables.each do |table|
          expected = Integer(table.data_row_count)
          actual = table.rows.length
          browser_count = Integer(table.data_browser_count)

          msg = "expected #{expected} rows, got #{actual} for table id=#{table.id}, browser reported: #{browser_count}"
          expect(actual).to eql(expected), msg
        end
      end

      it 'returns the correct number of cells under a row' do
        rows = browser.div(id: 'row-cells-test').trs(id: /^row/)
        expect(rows.length).to be > 0

        rows.each do |row|
          expected = Integer(row.data_cell_count)
          actual = row.cells.length
          browser_count = Integer(row.data_browser_count)

          msg = "expected #{expected} cells, got #{actual} for row id=#{row.id}, browser reported: #{browser_count}"
          expect(actual).to eql(expected), msg
        end
      end

      it 'returns the correct number of rows under a table section' do
        tbodies = browser.table(id: 'tbody-rows-test').tbodys(id: /^body/)
        expect(tbodies.length).to be > 0

        tbodies.each do |tbody|
          expected = Integer(tbody.data_rows_count)
          actual = tbody.rows.count
          browser_count = Integer(tbody.data_browser_count)

          msg = "expected #{expected} rows, got #{actual} for tbody id=#{tbody.id}, browser reported: #{browser_count}"
          expect(actual).to eql(expected), msg
        end
      end
    end
  end
end
