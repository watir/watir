require 'watirspec_helper'

describe 'Radio' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  # Exists method
  describe '#exists?' do
    it 'returns true if the radio button exists' do
      expect(browser.radio(id: 'new_user_newsletter_yes')).to exist
      expect(browser.radio(id: /new_user_newsletter_yes/)).to exist
      expect(browser.radio(name: 'new_user_newsletter')).to exist
      expect(browser.radio(name: /new_user_newsletter/)).to exist
      expect(browser.radio(value: 'yes')).to exist
      expect(browser.radio(value: /yes/)).to exist
      expect(browser.radio(text: 'Yes')).to exist
      expect(browser.radio(text: /Yes/)).to exist
      expect(browser.radio(class: 'huge')).to exist
      expect(browser.radio(class: /huge/)).to exist
      expect(browser.radio(index: 0)).to exist
      expect(browser.radio(xpath: "//input[@id='new_user_newsletter_yes']")).to exist
    end

    it 'returns the first radio if given no args' do
      expect(browser.radio).to exist
    end

    it 'returns true if the radio button exists (search by name and value)' do
      expect(browser.radio(name: 'new_user_newsletter', value: 'yes')).to exist
      browser.radio(xpath: "//input[@name='new_user_newsletter' and @value='yes']").set
    end

    it 'returns true for element with upper case type' do
      expect(browser.radio(id: 'new_user_newsletter_probably')).to exist
    end

    it 'returns false if the radio button does not exist' do
      expect(browser.radio(id: 'no_such_id')).to_not exist
      expect(browser.radio(id: /no_such_id/)).to_not exist
      expect(browser.radio(name: 'no_such_name')).to_not exist
      expect(browser.radio(name: /no_such_name/)).to_not exist
      expect(browser.radio(value: 'no_such_value')).to_not exist
      expect(browser.radio(value: /no_such_value/)).to_not exist
      expect(browser.radio(text: 'no_such_text')).to_not exist
      expect(browser.radio(text: /no_such_text/)).to_not exist
      expect(browser.radio(class: 'no_such_class')).to_not exist
      expect(browser.radio(class: /no_such_class/)).to_not exist
      expect(browser.radio(index: 1337)).to_not exist
      expect(browser.radio(xpath: "input[@id='no_such_id']")).to_not exist
    end

    it 'returns false if the radio button does not exist (search by name and value)' do
      expect(browser.radio(name: 'new_user_newsletter', value: 'no_such_value')).to_not exist
      expect(browser.radio(xpath: "//input[@name='new_user_newsletter' and @value='no_such_value']")).to_not exist
      expect(browser.radio(name: 'no_such_name', value: 'yes')).to_not exist
      expect(browser.radio(xpath: "//input[@name='no_such_name' and @value='yes']")).to_not exist
    end

    it 'returns true for radios with a string value' do
      expect(browser.radio(name: 'new_user_newsletter', value: 'yes')).to exist
      expect(browser.radio(name: 'new_user_newsletter', value: 'no')).to exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.radio(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  # Attribute methods
  describe '#id' do
    it 'returns the id attribute if the radio exists and has an attribute' do
      expect(browser.radio(index: 0).id).to eq 'new_user_newsletter_yes'
    end

    it "returns an empty string if the radio exists and the attribute doesn't" do
      expect(browser.radio(index: 2).id).to eq ''
    end

    it "raises UnknownObjectException if the radio doesn't exist" do
      expect { browser.radio(index: 1337).id }.to raise_unknown_object_exception
    end
  end

  describe '#name' do
    it 'returns the name attribute if the radio exists' do
      expect(browser.radio(id: 'new_user_newsletter_yes').name).to eq 'new_user_newsletter'
    end

    it "returns an empty string if the radio exists and the attribute doesn't" do
      expect(browser.radio(id: 'new_user_newsletter_absolutely').name).to eq ''
    end

    it "raises UnknownObjectException if the radio doesn't exist" do
      expect { browser.radio(index: 1337).name }.to raise_unknown_object_exception
    end
  end

  describe '#text' do
    it 'returns the text if the radio exists' do
      expect(browser.radio(id: 'new_user_newsletter_yes').text).to eq 'Yes'
    end

    it "raises UnknownObjectException if the radio doesn't exist" do
      expect { browser.radio(index: 1337).text }.to raise_unknown_object_exception
    end

    it 'returns empty string when there is no label' do
      form = browser.form(id: 'new_user')
      expect(form.radio(index: 2).text).to eq ''
    end
  end

  describe '#title' do
    it 'returns the title attribute if the radio exists' do
      expect(browser.radio(id: 'new_user_newsletter_no').title).to eq 'Traitor!'
    end

    it "returns an empty string if the radio exists and the attribute doesn't" do
      expect(browser.radio(id: 'new_user_newsletter_yes').title).to eq ''
    end

    it "raises UnknownObjectException if the radio doesn't exist" do
      expect { browser.radio(index: 1337).title }.to raise_unknown_object_exception
    end
  end

  describe '#type' do
    it 'returns the type attribute if the radio exists' do
      expect(browser.radio(index: 0).type).to eq 'radio'
    end

    it "raises UnknownObjectException if the radio doesn't exist" do
      expect { browser.radio(index: 1337).type }.to raise_unknown_object_exception
    end
  end

  describe '#value' do
    it 'returns the value attribute if the radio exists' do
      expect(browser.radio(id: 'new_user_newsletter_yes').value).to eq 'yes'
    end

    it "raises UnknownObjectException if the radio doesn't exist" do
      expect { browser.radio(index: 1337).value }.to raise_unknown_object_exception
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.radio(index: 0)).to respond_to(:class_name)
      expect(browser.radio(index: 0)).to respond_to(:id)
      expect(browser.radio(index: 0)).to respond_to(:name)
      expect(browser.radio(index: 0)).to respond_to(:title)
      expect(browser.radio(index: 0)).to respond_to(:type)
      expect(browser.radio(index: 0)).to respond_to(:value)
    end
  end

  # Access methods
  describe '#enabled?' do
    it 'returns true if the radio button is enabled' do
      expect(browser.radio(id: 'new_user_newsletter_yes')).to be_enabled
      expect(browser.radio(xpath: "//input[@id='new_user_newsletter_yes']")).to be_enabled
    end

    it 'returns false if the radio button is disabled' do
      expect(browser.radio(id: 'new_user_newsletter_nah')).to_not be_enabled
      expect(browser.radio(xpath: "//input[@id='new_user_newsletter_nah']")).to_not be_enabled
    end

    it "raises UnknownObjectException if the radio button doesn't exist" do
      expect { browser.radio(id: 'no_such_id').enabled? }.to raise_unknown_object_exception
      expect { browser.radio(xpath: "//input[@id='no_such_id']").enabled? }.to raise_unknown_object_exception
    end
  end

  describe '#disabled?' do
    it 'returns true if the radio is disabled' do
      expect(browser.radio(id: 'new_user_newsletter_nah')).to be_disabled
    end

    it 'returns false if the radio is enabled' do
      expect(browser.radio(id: 'new_user_newsletter_yes')).to_not be_disabled
    end

    it "raises UnknownObjectException if the radio doesn't exist" do
      expect { browser.radio(index: 1337).disabled? }.to raise_unknown_object_exception
    end
  end

  describe '#set' do
    it 'sets the radio button' do
      browser.radio(id: 'new_user_newsletter_no').set
      expect(browser.radio(id: 'new_user_newsletter_no')).to be_set
    end

    it 'sets the radio button when found by :xpath' do
      browser.radio(xpath: "//input[@id='new_user_newsletter_no']").set
      expect(browser.radio(xpath: "//input[@id='new_user_newsletter_no']")).to be_set
    end

    it 'fires the onclick event' do
      browser.radio(id: 'new_user_newsletter_no').set
      browser.radio(id: 'new_user_newsletter_yes').set
      expect(messages).to eq ['clicked: new_user_newsletter_no', 'clicked: new_user_newsletter_yes']
    end

    # http://webbugtrack.blogspot.com/2007/11/bug-193-onchange-does-not-fire-properly.html
    not_compliant_on :internet_explorer do
      it 'fires the onchange event' do
        browser.radio(value: 'certainly').set
        expect(messages).to eq ['changed: new_user_newsletter']

        browser.radio(value: 'certainly').set
        expect(messages).to eq ['changed: new_user_newsletter'] # no event fired here - didn't change

        browser.radio(value: 'yes').set
        browser.radio(value: 'certainly').set
        list = ['changed: new_user_newsletter', 'clicked: new_user_newsletter_yes', 'changed: new_user_newsletter']
        expect(messages).to eq list
      end
    end

    it "raises UnknownObjectException if the radio button doesn't exist" do
      expect { browser.radio(name: 'no_such_name').set }.to raise_unknown_object_exception
      expect { browser.radio(xpath: "//input[@name='no_such_name']").set }.to raise_unknown_object_exception
    end

    it 'raises ObjectDisabledException if the radio is disabled' do
      expect { browser.radio(id: 'new_user_newsletter_nah').set  }.to raise_object_disabled_exception
      expect { browser.radio(xpath: "//input[@id='new_user_newsletter_nah']").set }.to raise_object_disabled_exception
    end
  end

  # Other
  describe '#set?' do
    it 'returns true if the radio button is set' do
      expect(browser.radio(id: 'new_user_newsletter_yes')).to be_set
    end

    it 'returns false if the radio button unset' do
      expect(browser.radio(id: 'new_user_newsletter_no')).to_not be_set
    end

    it 'returns the state for radios with string values' do
      expect(browser.radio(name: 'new_user_newsletter', value: 'no')).to_not be_set
      browser.radio(name: 'new_user_newsletter', value: 'no').set
      expect(browser.radio(name: 'new_user_newsletter', value: 'no')).to be_set
      browser.radio(name: 'new_user_newsletter', value: 'yes').set
      expect(browser.radio(name: 'new_user_newsletter', value: 'no')).to_not be_set
    end

    it "raises UnknownObjectException if the radio button doesn't exist" do
      expect { browser.radio(id: 'no_such_id').set? }.to raise_unknown_object_exception
      expect { browser.radio(xpath: "//input[@id='no_such_id']").set? }.to raise_unknown_object_exception
    end
  end
end
