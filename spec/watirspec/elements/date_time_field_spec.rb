require 'watirspec_helper'

describe 'DateTimeField' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  # Exists method
  describe '#exists?' do
    it 'returns true if the element exists' do
      expect(browser.date_time_field(id: 'html5_datetime-local')).to exist
      expect(browser.date_time_field(id: /html5_datetime-local/)).to exist
      expect(browser.date_time_field(name: 'html5_datetime-local')).to exist
      expect(browser.date_time_field(name: /html5_datetime-local/)).to exist
      expect(browser.date_time_field(text: '')).to exist
      expect(browser.date_time_field(text: //)).to exist
      expect(browser.date_time_field(index: 0)).to exist

      # Firefox validates attribute "type" as "text" not "datetime-local"
      not_compliant_on :firefox do
        expect(browser.date_time_field(xpath: "//input[@id='html5_datetime-local']")).to exist
      end

      expect(browser.date_time_field(label: 'HTML5 Datetime Local')).to exist
      expect(browser.date_time_field(label: /Local$/)).to exist
    end

    it 'returns the date-time field if given no args' do
      expect(browser.date_time_field).to exist
    end

    bug 'https://bugzilla.mozilla.org/show_bug.cgi?id=1424984', :firefox do
      it 'respects date-time fields types' do
        expect(browser.date_time_field.type).to eq('datetime-local')
      end
    end

    it 'returns false if the element does not exist' do
      expect(browser.date_time_field(id: 'no_such_id')).to_not exist
      expect(browser.date_time_field(id: /no_such_id/)).to_not exist
      expect(browser.date_time_field(name: 'no_such_name')).to_not exist
      expect(browser.date_time_field(name: /no_such_name/)).to_not exist
      expect(browser.date_time_field(value: 'no_such_value')).to_not exist
      expect(browser.date_time_field(value: /no_such_value/)).to_not exist
      expect(browser.date_time_field(text: 'no_such_text')).to_not exist
      expect(browser.date_time_field(text: /no_such_text/)).to_not exist
      expect(browser.date_time_field(class: 'no_such_class')).to_not exist
      expect(browser.date_time_field(class: /no_such_class/)).to_not exist
      expect(browser.date_time_field(index: 1337)).to_not exist
      expect(browser.date_time_field(xpath: "//input[@id='no_such_id']")).to_not exist
      expect(browser.date_time_field(label: 'bad label')).to_not exist
      expect(browser.date_time_field(label: /bad label/)).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.date_time_field(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  # Attribute methods
  describe '#id' do
    it 'returns the id attribute if the date-time field exists' do
      expect(browser.date_time_field(name: 'html5_datetime-local').id).to eq 'html5_datetime-local'
    end

    it "raises UnknownObjectException if the date-time field doesn't exist" do
      expect { browser.date_time_field(index: 1337).id }.to raise_unknown_object_exception
    end
  end

  describe '#name' do
    it 'returns the name attribute if the date-time field exists' do
      expect(browser.date_time_field(id: 'html5_datetime-local').name).to eq 'html5_datetime-local'
    end

    it "raises UnknownObjectException if the date-time field doesn't exist" do
      expect { browser.date_time_field(index: 1337).name }.to raise_unknown_object_exception
    end
  end

  describe '#type' do
    bug 'https://bugzilla.mozilla.org/show_bug.cgi?id=1424984', :firefox do
      it 'returns the type attribute if the date-time field exists' do
        expect(browser.date_time_field(id: 'html5_datetime-local').type).to eq 'datetime-local'
      end
    end

    it "raises UnknownObjectException if the date-time field doesn't exist" do
      expect { browser.date_time_field(index: 1337).type }.to raise_unknown_object_exception
    end
  end

  describe '#value' do
    it 'returns the value attribute if the date-time field exists' do
      expect(browser.date_time_field(id: 'html5_datetime-local').value).to eq ''
    end

    it "raises UnknownObjectException if the date-time field doesn't exist" do
      expect { browser.date_time_field(index: 1337).value }.to raise_unknown_object_exception
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.date_time_field).to respond_to(:class_name)
      expect(browser.date_time_field).to respond_to(:id)
      expect(browser.date_time_field).to respond_to(:name)
      expect(browser.date_time_field).to respond_to(:title)
      expect(browser.date_time_field).to respond_to(:type)
      expect(browser.date_time_field).to respond_to(:value)
    end
  end

  # Access methods
  describe '#enabled?' do
    it 'returns true for enabled date-time fields' do
      expect(browser.browser.date_time_field(id: 'html5_datetime-local')).to be_enabled
    end

    it "raises UnknownObjectException if the date-time field doesn't exist" do
      expect { browser.browser.date_time_field(id: 'no_such_id').enabled? }.to raise_unknown_object_exception
    end
  end

  # Manipulation methods
  describe '#value= ' do
    it 'sets the value of the element' do
      date_time = Time.now
      date_time_field = browser.date_time_field(id: 'html5_datetime-local')
      date_time_field.value = date_time
      expect(Time.parse(date_time_field.value).strftime('%Y-%m-%dT%H:%M'))
        .to eq date_time.strftime('%Y-%m-%dT%H:%M')
    end

    it 'sets the value when accessed through the enclosing Form' do
      date_time = Time.now
      date_time_field = browser.form(id: 'new_user').date_time_field(id: 'html5_datetime-local')
      date_time_field.value = date_time
      expect(Time.parse(date_time_field.value).strftime('%Y-%m-%dT%H:%M'))
        .to eq date_time.strftime('%Y-%m-%dT%H:%M')
    end

    it "raises UnknownObjectException if the date-time field doesn't exist" do
      expect { browser.date_time_field(id: 'no_such_id').value = Time.now }.to raise_unknown_object_exception
    end

    it 'raises ArgumentError if using non-Date parameter' do
      expect { browser.date_time_field(id: 'no_such_id').value = 'foo' }.to raise_exception ArgumentError
    end
  end

  describe '#set!' do
    it 'sets the value of the element' do
      date_time = Time.now
      date_time_field = browser.date_time_field(id: 'html5_datetime-local')
      date_time_field.set! date_time
      expect(Time.parse(date_time_field.value).strftime('%Y-%m-%dT%H:%M'))
        .to eq date_time.strftime('%Y-%m-%dT%H:%M')
    end

    it 'sets the value when accessed through the enclosing Form' do
      date_time = Time.now
      date_time_field = browser.form(id: 'new_user').date_time_field(id: 'html5_datetime-local')
      date_time_field.set! date_time
      expect(Time.parse(date_time_field.value).strftime('%Y-%m-%dT%H:%M'))
        .to eq date_time.strftime('%Y-%m-%dT%H:%M')
    end

    it 'raises ArgumentError when no arguments are provided' do
      expect { browser.date_time_field(id: 'html5_datetime-local').set! }.to raise_exception ArgumentError
    end

    it "raises UnknownObjectException if the date-time field doesn't exist" do
      expect { browser.date_time_field(id: 'no_such_id').set!(Time.now) }.to raise_unknown_object_exception
    end
  end

  describe '#set' do
    it 'sets the value of the element' do
      date_time = Time.now
      date_time_field = browser.date_time_field(id: 'html5_datetime-local')
      date_time_field.set(date_time)
      expect(Time.parse(date_time_field.value).strftime('%Y-%m-%dT%H:%M'))
        .to eq date_time.strftime('%Y-%m-%dT%H:%M')
    end

    it 'sets the value when accessed through the enclosing Form' do
      date_time = Time.now
      date_time_field = browser.form(id: 'new_user').date_time_field(id: 'html5_datetime-local')
      date_time_field.set date_time
      expect(Time.parse(date_time_field.value).strftime('%Y-%m-%dT%H:%M'))
        .to eq date_time.strftime('%Y-%m-%dT%H:%M')
    end

    it 'raises ArgumentError when no arguments are provided' do
      expect { browser.date_time_field(id: 'html5_datetime-local').set }.to raise_exception ArgumentError
    end

    it "raises UnknownObjectException if the date-time field doesn't exist" do
      expect { browser.date_time_field(id: 'no_such_id').set(Time.now) }.to raise_unknown_object_exception
    end
  end
end
