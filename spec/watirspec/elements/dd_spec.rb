require 'watirspec_helper'

describe 'Dd' do
  before :each do
    browser.goto(WatirSpec.url_for('definition_lists.html'))
  end

  # Exists method
  describe '#exists?' do
    it 'returns true if the element exists' do
      expect(browser.dd(id: 'someone')).to exist
      expect(browser.dd(class: 'name')).to exist
      expect(browser.dd(xpath: "//dd[@id='someone']")).to exist
      expect(browser.dd(index: 0)).to exist
    end

    it 'returns the first dd if given no args' do
      expect(browser.dd).to exist
    end

    it 'returns false if the element does not exist' do
      expect(browser.dd(id: 'no_such_id')).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.dd(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  # Attribute methods
  describe '#id' do
    it 'returns the id attribute if the element exists' do
      expect(browser.dd(class: 'name').id).to eq 'someone'
    end

    it "returns an empty string if the element exists, but the attribute doesn't" do
      expect(browser.dd(class: 'address').id).to eq ''
    end

    it 'raises UnknownObjectException if the element does not exist' do
      expect { browser.dd(id: 'no_such_id').id }.to raise_unknown_object_exception
      expect { browser.dd(title: 'no_such_id').id }.to raise_unknown_object_exception
      expect { browser.dd(index: 1337).id }.to raise_unknown_object_exception
    end
  end

  describe '#title' do
    it 'returns the title of the element' do
      expect(browser.dd(class: 'name').title).to eq 'someone'
    end
  end

  describe '#text' do
    it 'returns the text of the element' do
      expect(browser.dd(id: 'someone').text).to eq 'John Doe'
    end

    bug 'Safari does not strip text', :safari do
      it 'returns an empty string if the element exists but contains no text' do
        expect(browser.dd(class: 'noop').text).to eq ''
      end
    end

    it 'raises UnknownObjectException if the element does not exist' do
      expect { browser.dd(id: 'no_such_id').text }.to raise_unknown_object_exception
      expect { browser.dd(title: 'no_such_title').text }.to raise_unknown_object_exception
      expect { browser.dd(index: 1337).text }.to raise_unknown_object_exception
      expect { browser.dd(xpath: "//dd[@id='no_such_id']").text }.to raise_unknown_object_exception
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.dd(index: 0)).to respond_to(:id)
      expect(browser.dd(index: 0)).to respond_to(:class_name)
      expect(browser.dd(index: 0)).to respond_to(:style)
      expect(browser.dd(index: 0)).to respond_to(:text)
      expect(browser.dd(index: 0)).to respond_to(:title)
    end
  end

  # Manipulation methods
  describe '#click' do
    it 'fires events when clicked' do
      expect(browser.dd(title: 'education').text).to_not eq 'changed'
      browser.dd(title: 'education').click
      expect(browser.dd(title: 'education').text).to eq 'changed'
    end

    it 'raises UnknownObjectException if the element does not exist' do
      expect { browser.dd(id: 'no_such_id').click }.to raise_unknown_object_exception
      expect { browser.dd(title: 'no_such_title').click }.to raise_unknown_object_exception
      expect { browser.dd(index: 1337).click }.to raise_unknown_object_exception
      expect { browser.dd(xpath: "//dd[@id='no_such_id']").click }.to raise_unknown_object_exception
    end
  end

  describe '#html' do
    it 'returns the HTML of the element' do
      html = browser.dd(id: 'someone').html
      expect(html).to match(/John Doe/m)
      expect(html).to_not include('</body>')
    end
  end
end
