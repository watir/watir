require 'watirspec_helper'

describe 'Dt' do
  before :each do
    browser.goto(WatirSpec.url_for('definition_lists.html'))
  end

  # Exists method
  describe '#exists?' do
    it 'returns true if the element exists' do
      expect(browser.dt(id: 'experience')).to exist
      expect(browser.dt(class: 'current-industry')).to exist
      expect(browser.dt(xpath: "//dt[@id='experience']")).to exist
      expect(browser.dt(index: 0)).to exist
    end

    it 'returns the first dt if given no args' do
      expect(browser.dt).to exist
    end

    it 'returns false if the element does not exist' do
      expect(browser.dt(id: 'no_such_id')).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.dt(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  # Attribute methods
  describe '#id' do
    it 'returns the id attribute if the element exists' do
      expect(browser.dt(class: 'industry').id).to eq 'experience'
    end

    it "returns an empty string if the element exists, but the attribute doesn't" do
      expect(browser.dt(class: 'current-industry').id).to eq ''
    end

    it 'raises UnknownObjectException if the element does not exist' do
      expect { browser.dt(id: 'no_such_id').id }.to raise_unknown_object_exception
      expect { browser.dt(title: 'no_such_id').id }.to raise_unknown_object_exception
      expect { browser.dt(index: 1337).id }.to raise_unknown_object_exception
    end
  end

  describe '#title' do
    it 'returns the title of the element' do
      expect(browser.dt(id: 'experience').title).to eq 'experience'
    end
  end

  describe '#text' do
    it 'returns the text of the element' do
      expect(browser.dt(id: 'experience').text).to eq 'Experience'
    end

    it 'returns an empty string if the element exists but contains no text' do
      expect(browser.dt(class: 'noop').text).to eq ''
    end

    it 'raises UnknownObjectException if the element does not exist' do
      expect { browser.dt(id: 'no_such_id').text }.to raise_unknown_object_exception
      expect { browser.dt(title: 'no_such_title').text }.to raise_unknown_object_exception
      expect { browser.dt(index: 1337).text }.to raise_unknown_object_exception
      expect { browser.dt(xpath: "//dt[@id='no_such_id']").text }.to raise_unknown_object_exception
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.dt(index: 0)).to respond_to(:id)
      expect(browser.dt(index: 0)).to respond_to(:class_name)
      expect(browser.dt(index: 0)).to respond_to(:style)
      expect(browser.dt(index: 0)).to respond_to(:text)
      expect(browser.dt(index: 0)).to respond_to(:title)
    end
  end

  # Manipulation methods
  describe '#click' do
    it 'fires events when clicked' do
      expect(browser.dt(id: 'education').text).to_not eq 'changed'
      browser.dt(id: 'education').click
      expect(browser.dt(id: 'education').text).to eq 'changed'
    end

    it 'raises UnknownObjectException if the element does not exist' do
      expect { browser.dt(id: 'no_such_id').click }.to raise_unknown_object_exception
      expect { browser.dt(title: 'no_such_title').click }.to raise_unknown_object_exception
      expect { browser.dt(index: 1337).click }.to raise_unknown_object_exception
      expect { browser.dt(xpath: "//dt[@id='no_such_id']").click }.to raise_unknown_object_exception
    end
  end

  describe '#html' do
    it 'returns the HTML of the element' do
      html = browser.dt(id: 'name').html
      expect(html).to match(%r{<div>.*Name.*</div>}mi)
      expect(html).to_not include('</body>')
    end
  end
end
