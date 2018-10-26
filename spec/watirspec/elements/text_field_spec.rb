require 'watirspec_helper'

describe 'TextField' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  # Exists method
  describe '#exists?' do
    it 'returns true if the element exists' do
      expect(browser.text_field(id: 'new_user_email')).to exist
      expect(browser.text_field(id: /new_user_email/)).to exist
      expect(browser.text_field(name: 'new_user_email')).to exist
      expect(browser.text_field(name: /new_user_email/)).to exist
      expect(browser.text_field(name: /new_user_occupation/i)).to exist
      expect(browser.text_field(value: 'Developer')).to exist
      expect(browser.text_field(value: /Developer/)).to exist
      expect(browser.text_field(class: 'name')).to exist
      expect(browser.text_field(class: /name/)).to exist
      expect(browser.text_field(index: 0)).to exist
      expect(browser.text_field(xpath: "//input[@id='new_user_email']")).to exist
      expect(browser.text_field(label: 'First name')).to exist
      expect(browser.text_field(label: /(q|a)st? name/)).to exist
      expect(browser.text_field(label: 'Without for')).to exist
      expect(browser.text_field(label: /Without for/)).to exist
      expect(browser.text_field(label: 'With hidden text')).to exist
      expect(browser.text_field(label: 'With text')).not_to exist
      expect(browser.text_field(visible_label: 'With hidden text')).not_to exist
      expect(browser.text_field(visible_label: 'With text')).to exist

      # These will work after text is deprecated for visible_text
      # expect(browser.text_field(label: /With hidden text/)).to exist
      # expect(browser.text_field(label: /With text/)).not_to exist

      expect(browser.text_field(visible_label: /With text/)).to exist
      expect(browser.text_field(visible_label: /With hidden text/)).not_to exist
    end

    it 'locates value of text_field using text locators' do
      browser.text_field(id: 'new_user_occupation').set 'Firefighter'

      expect(browser.text_field(text: 'Firefighter')).to exist
      expect(browser.text_field(text: /Fire/)).to exist
      expect(browser.text_field(visible_text: 'Firefighter')).to exist
      expect(browser.text_field(visible_text: /Fire/)).to exist
    end

    it 'returns the first text field if given no args' do
      expect(browser.text_field).to exist
    end

    it 'respects text fields types' do
      expect(browser.text_field.type).to eq('text')
    end

    it 'returns true if the element exists (no type attribute)' do
      expect(browser.text_field(id: 'new_user_first_name')).to exist
    end

    it 'returns true if the element exists (invalid type attribute)' do
      expect(browser.text_field(id: 'new_user_last_name')).to exist
    end

    it 'returns true for element with upper case type' do
      expect(browser.text_field(id: 'new_user_email_confirm')).to exist
    end

    it 'returns true for element with unknown type attribute' do
      expect(browser.text_field(id: 'unknown_text_field')).to exist
    end

    it 'returns false if the element does not exist' do
      expect(browser.text_field(id: 'no_such_id')).to_not exist
      expect(browser.text_field(id: /no_such_id/)).to_not exist
      expect(browser.text_field(name: 'no_such_name')).to_not exist
      expect(browser.text_field(name: /no_such_name/)).to_not exist
      expect(browser.text_field(value: 'no_such_value')).to_not exist
      expect(browser.text_field(value: /no_such_value/)).to_not exist
      expect(browser.text_field(text: 'no_such_text')).to_not exist
      expect(browser.text_field(text: /no_such_text/)).to_not exist
      expect(browser.text_field(class: 'no_such_class')).to_not exist
      expect(browser.text_field(class: /no_such_class/)).to_not exist
      expect(browser.text_field(index: 1337)).to_not exist
      expect(browser.text_field(xpath: "//input[@id='no_such_id']")).to_not exist
      expect(browser.text_field(label: 'bad label')).to_not exist
      expect(browser.text_field(label: /bad label/)).to_not exist

      # input type='hidden' should not be found by #text_field
      expect(browser.text_field(id: 'new_user_interests_dolls')).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.text_field(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  # Attribute methods
  describe '#id' do
    it 'returns the id attribute if the text field exists' do
      expect(browser.text_field(index: 4).id).to eq 'new_user_occupation'
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(index: 1337).id }.to raise_unknown_object_exception
    end
  end

  describe '#name' do
    it 'returns the name attribute if the text field exists' do
      expect(browser.text_field(index: 3).name).to eq 'new_user_email_confirm'
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(index: 1337).name }.to raise_unknown_object_exception
    end
  end

  describe '#title' do
    it 'returns the title attribute if the text field exists' do
      expect(browser.text_field(id: 'new_user_code').title).to eq 'Your personal code'
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(index: 1337).title }.to raise_unknown_object_exception
    end
  end

  describe '#type' do
    it 'returns the type attribute if the text field exists' do
      expect(browser.text_field(index: 3).type).to eq 'text'
    end

    it "returns 'text' if the type attribute is invalid" do
      expect(browser.text_field(id: 'new_user_last_name').type).to eq 'text'
    end

    it "returns 'text' if the type attribute does not exist" do
      expect(browser.text_field(id: 'new_user_first_name').type).to eq 'text'
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(index: 1337).type }.to raise_unknown_object_exception
    end
  end

  describe '#value' do
    it 'returns the value attribute if the text field exists' do
      expect(browser.text_field(name: 'new_user_occupation').value).to eq 'Developer'
      expect(browser.text_field(index: 4).value).to eq 'Developer'
      expect(browser.text_field(name: /new_user_occupation/i).value).to eq 'Developer'
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(index: 1337).value }.to raise_unknown_object_exception
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.text_field(index: 0)).to respond_to(:class_name)
      expect(browser.text_field(index: 0)).to respond_to(:id)
      expect(browser.text_field(index: 0)).to respond_to(:name)
      expect(browser.text_field(index: 0)).to respond_to(:title)
      expect(browser.text_field(index: 0)).to respond_to(:type)
      expect(browser.text_field(index: 0)).to respond_to(:value)
    end
  end

  # Access methods
  describe '#enabled?' do
    it 'returns true for enabled text fields' do
      expect(browser.text_field(name: 'new_user_occupation')).to be_enabled
      expect(browser.text_field(id: 'new_user_email')).to be_enabled
    end

    it 'returns false for disabled text fields' do
      expect(browser.text_field(name: 'new_user_species')).to_not be_enabled
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(id: 'no_such_id').enabled? }.to raise_unknown_object_exception
    end
  end

  describe '#disabled?' do
    it 'returns true if the text field is disabled' do
      expect(browser.text_field(id: 'new_user_species')).to be_disabled
    end

    it 'returns false if the text field is enabled' do
      expect(browser.text_field(index: 0)).to_not be_disabled
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(index: 1337).disabled? }.to raise_unknown_object_exception
    end
  end

  describe '#readonly?' do
    it 'returns true for read-only text fields' do
      expect(browser.text_field(name: 'new_user_code')).to be_readonly
      expect(browser.text_field(id: 'new_user_code')).to be_readonly
    end

    it 'returns false for writable text fields' do
      expect(browser.text_field(name: 'new_user_email')).to_not be_readonly
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(id: 'no_such_id').readonly? }.to raise_unknown_object_exception
    end

    it 'raises UnknownReadOnlyException if sending keys to readonly element' do
      expect { browser.text_field(id: 'new_user_code').set 'foo' }.to raise_object_read_only_exception
    end
  end
end
