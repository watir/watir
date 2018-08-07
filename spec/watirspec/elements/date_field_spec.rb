require 'watirspec_helper'

describe 'DateField' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  # Exists method
  describe '#exists?' do
    it 'returns true if the element exists' do
      expect(browser.date_field(id: 'html5_date')).to exist
      expect(browser.date_field(id: /html5_date/)).to exist
      expect(browser.date_field(name: 'html5_date')).to exist
      expect(browser.date_field(name: /html5_date/)).to exist
      expect(browser.date_field(text: '')).to exist
      expect(browser.date_field(text: //)).to exist
      expect(browser.date_field(index: 0)).to exist
      expect(browser.date_field(xpath: "//input[@id='html5_date']")).to exist
      expect(browser.date_field(label: 'HTML5 Date')).to exist
      expect(browser.date_field(label: /Date$/)).to exist
    end

    it 'returns the date field if given no args' do
      expect(browser.date_field).to exist
    end

    it 'respects date fields types' do
      expect(browser.date_field.type).to eq('date')
    end

    it 'returns false if the element does not exist' do
      expect(browser.date_field(id: 'no_such_id')).to_not exist
      expect(browser.date_field(id: /no_such_id/)).to_not exist
      expect(browser.date_field(name: 'no_such_name')).to_not exist
      expect(browser.date_field(name: /no_such_name/)).to_not exist
      expect(browser.date_field(value: 'no_such_value')).to_not exist
      expect(browser.date_field(value: /no_such_value/)).to_not exist
      expect(browser.date_field(text: 'no_such_text')).to_not exist
      expect(browser.date_field(text: /no_such_text/)).to_not exist
      expect(browser.date_field(class: 'no_such_class')).to_not exist
      expect(browser.date_field(class: /no_such_class/)).to_not exist
      expect(browser.date_field(index: 1337)).to_not exist
      expect(browser.date_field(xpath: "//input[@id='no_such_id']")).to_not exist
      expect(browser.date_field(label: 'bad label')).to_not exist
      expect(browser.date_field(label: /bad label/)).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.date_field(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  # Attribute methods
  describe '#id' do
    it 'returns the id attribute if the date field exists' do
      expect(browser.date_field(name: 'html5_date').id).to eq 'html5_date'
    end

    it "raises UnknownObjectException if the date field doesn't exist" do
      expect { browser.date_field(index: 1337).id }.to raise_unknown_object_exception
    end
  end

  describe '#name' do
    it 'returns the name attribute if the date field exists' do
      expect(browser.date_field(id: 'html5_date').name).to eq 'html5_date'
    end

    it "raises UnknownObjectException if the date field doesn't exist" do
      expect { browser.date_field(index: 1337).name }.to raise_unknown_object_exception
    end
  end

  describe '#type' do
    it 'returns the type attribute if the date field exists' do
      expect(browser.date_field(id: 'html5_date').type).to eq 'date'
    end

    it "raises UnknownObjectException if the date field doesn't exist" do
      expect { browser.date_field(index: 1337).type }.to raise_unknown_object_exception
    end
  end

  describe '#value' do
    it 'returns the value attribute if the date field exists' do
      expect(browser.date_field(id: 'html5_date').value).to eq ''
    end

    it "raises UnknownObjectException if the date field doesn't exist" do
      expect { browser.date_field(index: 1337).value }.to raise_unknown_object_exception
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.date_field).to respond_to(:class_name)
      expect(browser.date_field).to respond_to(:id)
      expect(browser.date_field).to respond_to(:name)
      expect(browser.date_field).to respond_to(:title)
      expect(browser.date_field).to respond_to(:type)
      expect(browser.date_field).to respond_to(:value)
    end
  end

  # Access methods
  describe '#enabled?' do
    it 'returns true for enabled date fields' do
      expect(browser.browser.date_field(id: 'html5_date')).to be_enabled
    end

    it "raises UnknownObjectException if the date field doesn't exist" do
      expect { browser.browser.date_field(id: 'no_such_id').enabled? }.to raise_unknown_object_exception
    end
  end

  # Manipulation methods
  describe '#value= ' do
    it 'sets the value of the element' do
      date = browser.date_field(id: 'html5_date')
      date.value = Date.today
      expect(Date.parse(date.value)).to eq Date.today
    end

    it 'sets the value when accessed through the enclosing Form' do
      date_field = browser.form(id: 'new_user').date_field(id: 'html5_date')
      date_field.value = Date.today
      expect(Date.parse(date_field.value)).to eq Date.today
    end

    it "raises UnknownObjectException if the date field doesn't exist" do
      expect { browser.date_field(id: 'no_such_id').value = Date.today }.to raise_unknown_object_exception
    end

    it 'raises ArgumentError if using non-Date parameter' do
      expect { browser.date_field(id: 'no_such_id').value = 'foo' }.to raise_exception ArgumentError
    end
  end

  describe '#set!' do
    it 'sets the value of the element' do
      date = browser.date_field(id: 'html5_date')
      date.set!(Date.today)
      expect(Date.parse(date.value)).to eq Date.today
    end

    it 'sets the value when accessed through the enclosing Form' do
      date_field = browser.form(id: 'new_user').date_field(id: 'html5_date')
      date_field.set!(Date.today)
      expect(Date.parse(date_field.value)).to eq Date.today
    end

    it 'raises ArgumentError when no arguments are provided' do
      expect { browser.date_field(id: 'html5_date').set! }.to raise_exception ArgumentError
    end

    it "raises UnknownObjectException if the date field doesn't exist" do
      expect { browser.date_field(id: 'no_such_id').set!(Date.today) }.to raise_unknown_object_exception
    end
  end

  describe '#set' do
    it 'sets the value of the element' do
      date = browser.date_field(id: 'html5_date')
      date.set(Date.today)
      expect(Date.parse(date.value)).to eq Date.today
    end

    it 'sets the value when accessed through the enclosing Form' do
      date_field = browser.form(id: 'new_user').date_field(id: 'html5_date')
      date_field.set(Date.today)
      expect(Date.parse(date_field.value)).to eq Date.today
    end

    it 'raises ArgumentError when no arguments are provided' do
      expect { browser.date_field(id: 'html5_date').set }.to raise_exception ArgumentError
    end

    it "raises UnknownObjectException if the date field doesn't exist" do
      expect { browser.date_field(id: 'no_such_id').set(Date.today) }.to raise_unknown_object_exception
    end
  end
end
