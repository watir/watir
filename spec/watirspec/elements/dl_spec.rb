# frozen_string_literal: true

require 'watirspec_helper'

module Watir
  describe DList do
    before do
      browser.goto(WatirSpec.url_for('definition_lists.html'))
    end

    # Exists method
    describe '#exists?' do
      it 'returns true if the element exists' do
        expect(browser.dl(id: 'experience-list')).to exist
        expect(browser.dl(class: 'list')).to exist
        expect(browser.dl(xpath: "//dl[@id='experience-list']")).to exist
        expect(browser.dl(index: 0)).to exist
      end

      it 'returns the first dl if given no args' do
        expect(browser.dl).to exist
      end

      it 'returns false if the element does not exist' do
        expect(browser.dl(id: 'no_such_id')).not_to exist
      end

      it "raises TypeError when 'what' argument is invalid" do
        expect { browser.dl(id: 3.14).exists? }.to raise_error(TypeError)
      end
    end

    # Attribute methods
    describe '#id' do
      it 'returns the id attribute if the element exists' do
        expect(browser.dl(class: 'list').id).to eq 'experience-list'
      end

      it "returns an empty string if the element exists, but the attribute doesn't" do
        expect(browser.dl(class: 'personalia').id).to eq ''
      end

      it 'raises UnknownObjectException if the element does not exist' do
        expect { browser.dl(id: 'no_such_id').id }.to raise_unknown_object_exception
        expect { browser.dl(title: 'no_such_id').id }.to raise_unknown_object_exception
        expect { browser.dl(index: 1337).id }.to raise_unknown_object_exception
      end
    end

    describe '#title' do
      it 'returns the id attribute if the element exists' do
        expect(browser.dl(class: 'list').title).to eq 'experience'
      end
    end

    describe '#text' do
      it 'returns the text of the element' do
        expect(browser.dl(id: 'experience-list').text).to include('11 years')
      end

      it 'returns an empty string if the element exists but contains no text',
         except: {browser: :safari, reason: 'Safari does not strip text'} do
        expect(browser.dl(id: 'noop').text).to eq ''
      end

      it 'raises UnknownObjectException if the element does not exist' do
        expect { browser.dl(id: 'no_such_id').text }.to raise_unknown_object_exception
        expect { browser.dl(title: 'no_such_title').text }.to raise_unknown_object_exception
        expect { browser.dl(index: 1337).text }.to raise_unknown_object_exception
        expect { browser.dl(xpath: "//dl[@id='no_such_id']").text }.to raise_unknown_object_exception
      end
    end

    describe '#respond_to?' do
      it 'returns true for all attribute methods' do
        expect(browser.dl(index: 0)).to respond_to(:id)
        expect(browser.dl(index: 0)).to respond_to(:class_name)
        expect(browser.dl(index: 0)).to respond_to(:style)
        expect(browser.dl(index: 0)).to respond_to(:text)
        expect(browser.dl(index: 0)).to respond_to(:title)
      end
    end

    # Manipulation methods
    describe '#click' do
      it 'fires events when clicked' do
        expect(browser.dt(id: 'name').text).not_to eq 'changed!'
        browser.dt(id: 'name').click
        expect(browser.dt(id: 'name').text).to eq 'changed!'
      end

      it 'raises UnknownObjectException if the element does not exist' do
        expect { browser.dl(id: 'no_such_id').click }.to raise_unknown_object_exception
        expect { browser.dl(title: 'no_such_title').click }.to raise_unknown_object_exception
        expect { browser.dl(index: 1337).click }.to raise_unknown_object_exception
        expect { browser.dl(xpath: "//dl[@id='no_such_id']").click }.to raise_unknown_object_exception
      end
    end

    describe '#html' do
      it 'returns the HTML of the element' do
        html = browser.dl(id: 'experience-list').html.downcase
        expect(html).to match(/<dt class=?"current-industry?">/)
        expect(html).not_to include('</body>')
      end
    end

    describe '#to_hash' do
      it 'converts the dl to a Hash' do
        expect(browser.dl(id: 'experience-list').to_hash).to eq({'Experience' => '11 years',
                                                                 'Education' => 'Master',
                                                                 'Current industry' => 'Architecture',
                                                                 'Previous industry experience' => 'Architecture'})
      end
    end
  end
end
