require 'watirspec_helper'

describe 'CheckBox' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  # Exists method

  describe '#exists?' do
    it 'returns true if the checkbox button exists' do
      expect(browser.checkbox(id: 'new_user_interests_books')).to exist
      expect(browser.checkbox(id: /new_user_interests_books/)).to exist
      expect(browser.checkbox(label: 'Cars')).to exist
      expect(browser.checkbox(label: /Cars/)).to exist
      expect(browser.checkbox(name: 'new_user_interests')).to exist
      expect(browser.checkbox(name: /new_user_interests/)).to exist
      expect(browser.checkbox(value: 'books')).to exist
      expect(browser.checkbox(value: /books/)).to exist
      # not sure what :text is supposed to represent here
      # browser.checkbox(text: "books").to exist
      # browser.checkbox(text: /books/).to exist
      expect(browser.checkbox(class: 'fun')).to exist
      expect(browser.checkbox(class: /fun/)).to exist
      expect(browser.checkbox(index: 0)).to exist
      expect(browser.checkbox(xpath: "//input[@id='new_user_interests_books']")).to exist
    end

    not_compliant_on :watigiri do
      it 'handles text_regexp deprecations for label locators' do
        expect {
          expect(browser.checkbox(label: /some visible/)).to exist
        }.to_not have_deprecated_text_regexp

        expect {
          expect(browser.checkbox(label: /some (visible|Jeff)/)).to exist
        }.to_not have_deprecated_text_regexp

        expect {
          expect(browser.checkbox(label: /this will not match/)).to exist
        }.to_not have_deprecated_text_regexp

        expect(browser.checkbox(label: /some visible some hidden/)).to_not exist

        expect {
          expect(browser.checkbox(label: /some visible$/)).to exist
        }.to have_deprecated_text_regexp
      end
    end

    it 'returns true if the checkbox button exists (search by name and value)' do
      expect(browser.checkbox(name: 'new_user_interests', value: 'cars')).to exist
      browser.checkbox(xpath: "//input[@name='new_user_interests' and @value='cars']").set
    end

    it 'returns the first checkbox if given no args' do
      expect(browser.checkbox).to exist
    end

    it 'returns false if the checkbox button does not exist' do
      expect(browser.checkbox(id: 'no_such_id')).to_not exist
      expect(browser.checkbox(id: /no_such_id/)).to_not exist
      expect(browser.checkbox(name: 'no_such_name')).to_not exist
      expect(browser.checkbox(name: /no_such_name/)).to_not exist
      expect(browser.checkbox(value: 'no_such_value')).to_not exist
      expect(browser.checkbox(value: /no_such_value/)).to_not exist
      expect(browser.checkbox(text: 'no_such_text')).to_not exist
      expect(browser.checkbox(text: /no_such_text/)).to_not exist
      expect(browser.checkbox(class: 'no_such_class')).to_not exist
      expect(browser.checkbox(class: /no_such_class/)).to_not exist
      expect(browser.checkbox(index: 1337)).to_not exist
      expect(browser.checkbox(xpath: "//input[@id='no_such_id']")).to_not exist
    end

    it 'returns false if the checkbox button does not exist (search by name and value)' do
      expect(browser.checkbox(name: 'new_user_interests', value: 'no_such_value')).to_not exist
      expect(browser.checkbox(xpath: "//input[@name='new_user_interests' and @value='no_such_value']")).to_not exist
      expect(browser.checkbox(name: 'no_such_name', value: 'cars')).to_not exist
      expect(browser.checkbox(xpath: "//input[@name='no_such_name' and @value='cars']")).to_not exist
    end

    it 'returns true for checkboxes with a string value' do
      expect(browser.checkbox(name: 'new_user_interests', value: 'books')).to exist
      expect(browser.checkbox(name: 'new_user_interests', value: 'cars')).to exist
    end

    it 'returns true for checkbox with upper case type' do
      expect(browser.checkbox(id: 'new_user_interests_draw')).to exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.checkbox(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  # Attribute methods
  describe '#id' do
    it 'returns the id attribute if the checkbox exists and has an attribute' do
      expect(browser.checkbox(index: 0).id).to eq 'new_user_interests_books'
    end

    it "returns an empty string if the checkbox exists and the attribute doesn't" do
      expect(browser.checkbox(index: 1).id).to eq ''
    end

    it "raises UnknownObjectException if the checkbox doesn't exist" do
      expect { browser.checkbox(index: 1337).id }.to raise_unknown_object_exception
    end
  end

  describe '#name' do
    it 'returns the name attribute if the checkbox exists' do
      expect(browser.checkbox(id: 'new_user_interests_books').name).to eq 'new_user_interests'
    end

    it "returns an empty string if the checkbox exists and the attribute doesn't" do
      expect(browser.checkbox(id: 'new_user_interests_food').name).to eq ''
    end

    it "raises UnknownObjectException if the checkbox doesn't exist" do
      expect { browser.checkbox(index: 1337).name }.to raise_unknown_object_exception
    end
  end

  describe '#title' do
    it 'returns the title attribute if the checkbox exists' do
      expect(browser.checkbox(id: 'new_user_interests_dancing').title).to eq 'Dancing is fun!'
    end

    it "returns an empty string if the checkbox exists and the attribute doesn't" do
      expect(browser.checkbox(id: 'new_user_interests_books').title).to eq ''
    end

    it "raises UnknownObjectException if the checkbox doesn't exist" do
      expect { browser.checkbox(index: 1337).title }.to raise_unknown_object_exception
    end
  end

  describe '#type' do
    it 'returns the type attribute if the checkbox exists' do
      expect(browser.checkbox(index: 0).type).to eq 'checkbox'
    end

    it "raises UnknownObjectException if the checkbox doesn't exist" do
      expect { browser.checkbox(index: 1337).type }.to raise_unknown_object_exception
    end
  end

  describe '#value' do
    it 'returns the value attribute if the checkbox exists' do
      expect(browser.checkbox(id: 'new_user_interests_books').value).to eq 'books'
    end

    it "raises UnknownObjectException if the checkbox doesn't exist" do
      expect { browser.checkbox(index: 1337).value }.to raise_unknown_object_exception
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.checkbox(index: 0)).to respond_to(:class_name)
      expect(browser.checkbox(index: 0)).to respond_to(:id)
      expect(browser.checkbox(index: 0)).to respond_to(:name)
      expect(browser.checkbox(index: 0)).to respond_to(:title)
      expect(browser.checkbox(index: 0)).to respond_to(:type)
      expect(browser.checkbox(index: 0)).to respond_to(:value)
    end
  end

  # Access methods

  describe '#enabled?' do
    it 'returns true if the checkbox button is enabled' do
      expect(browser.checkbox(id: 'new_user_interests_books')).to be_enabled
      expect(browser.checkbox(xpath: "//input[@id='new_user_interests_books']")).to be_enabled
    end

    it 'returns false if the checkbox button is disabled' do
      expect(browser.checkbox(id: 'new_user_interests_dentistry')).to_not be_enabled
      expect(browser.checkbox(xpath: "//input[@id='new_user_interests_dentistry']")).to_not be_enabled
    end

    it "raises UnknownObjectException if the checkbox button doesn't exist" do
      expect { browser.checkbox(id: 'no_such_id').enabled? }.to raise_unknown_object_exception
      expect { browser.checkbox(xpath: "//input[@id='no_such_id']").enabled? }.to raise_unknown_object_exception
    end
  end

  describe '#disabled?' do
    it 'returns true if the checkbox is disabled' do
      expect(browser.checkbox(id: 'new_user_interests_dentistry')).to be_disabled
    end

    it 'returns false if the checkbox is enabled' do
      expect(browser.checkbox(id: 'new_user_interests_books')).to_not be_disabled
    end

    it "raises UnknownObjectException if the checkbox doesn't exist" do
      expect { browser.checkbox(index: 1337).disabled? }.to raise_unknown_object_exception
    end
  end

  # Manipulation methods

  describe '#clear' do
    it 'raises ObjectDisabledException if the checkbox is disabled' do
      expect(browser.checkbox(id: 'new_user_interests_dentistry')).to_not be_set
      expect { browser.checkbox(id: 'new_user_interests_dentistry').clear }
        .to raise_object_disabled_exception
      expect { browser.checkbox(xpath: "//input[@id='new_user_interests_dentistry']").clear }
        .to raise_object_disabled_exception
    end

    it 'clears the checkbox button if it is set' do
      browser.checkbox(id: 'new_user_interests_books').clear
      expect(browser.checkbox(id: 'new_user_interests_books')).to_not be_set
    end

    it 'clears the checkbox button when found by :xpath' do
      browser.checkbox(xpath: "//input[@id='new_user_interests_books']").clear
      expect(browser.checkbox(xpath: "//input[@id='new_user_interests_books']")).to_not be_set
    end

    it "raises UnknownObjectException if the checkbox button doesn't exist" do
      expect { browser.checkbox(name: 'no_such_id').clear }.to raise_unknown_object_exception
      expect { browser.checkbox(xpath: "//input[@id='no_such_id']").clear }.to raise_unknown_object_exception
    end
  end

  describe '#set' do
    it 'sets the checkbox button' do
      browser.checkbox(id: 'new_user_interests_cars').set
      expect(browser.checkbox(id: 'new_user_interests_cars')).to be_set
    end

    it 'sets the checkbox button when found by :xpath' do
      browser.checkbox(xpath: "//input[@id='new_user_interests_cars']").set
      expect(browser.checkbox(xpath: "//input[@id='new_user_interests_cars']")).to be_set
    end

    it 'fires the onclick event' do
      expect(browser.button(id: 'disabled_button')).to be_disabled
      browser.checkbox(id: 'toggle_button_checkbox').set
      expect(browser.button(id: 'disabled_button')).to_not be_disabled
      browser.checkbox(id: 'toggle_button_checkbox').clear
      expect(browser.button(id: 'disabled_button')).to be_disabled
    end

    it "raises UnknownObjectException if the checkbox button doesn't exist" do
      expect { browser.checkbox(name: 'no_such_name').set }.to raise_unknown_object_exception
      expect { browser.checkbox(xpath: "//input[@name='no_such_name']").set }.to raise_unknown_object_exception
    end

    it 'raises ObjectDisabledException if the checkbox is disabled' do
      expect { browser.checkbox(id: 'new_user_interests_dentistry').set }
        .to raise_object_disabled_exception
      expect { browser.checkbox(xpath: "//input[@id='new_user_interests_dentistry']").set }
        .to raise_object_disabled_exception
    end
  end

  # Other

  describe '#set?' do
    it 'returns true if the checkbox button is set' do
      expect(browser.checkbox(id: 'new_user_interests_books')).to be_set
    end

    it 'returns false if the checkbox button unset' do
      expect(browser.checkbox(id: 'new_user_interests_cars')).to_not be_set
    end

    it 'returns the state for checkboxes with string values' do
      expect(browser.checkbox(name: 'new_user_interests', value: 'cars')).to_not be_set
      browser.checkbox(name: 'new_user_interests', value: 'cars').set
      expect(browser.checkbox(name: 'new_user_interests', value: 'cars')).to be_set
      browser.checkbox(name: 'new_user_interests', value: 'cars').clear
      expect(browser.checkbox(name: 'new_user_interests', value: 'cars')).to_not be_set
    end

    it "raises UnknownObjectException if the checkbox button doesn't exist" do
      expect { browser.checkbox(id: 'no_such_id').set? }.to raise_unknown_object_exception
      expect { browser.checkbox(xpath: "//input[@id='no_such_id']").set? }.to raise_unknown_object_exception
    end
  end
end
