require 'watirspec_helper'

describe 'Button' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  # Exists method
  describe '#exists?' do
    it 'returns true if the button exists (tag = :input)' do
      expect(browser.button(id: 'new_user_submit')).to exist
      expect(browser.button(id: /new_user_submit/)).to exist
      expect(browser.button(name: 'new_user_reset')).to exist
      expect(browser.button(name: /new_user_reset/)).to exist
      expect(browser.button(value: 'Button')).to exist
      expect(browser.button(value: /Button/)).to exist
      not_compliant_on :internet_explorer do
        expect(browser.button(src: 'images/button.png')).to exist
      end
      expect(browser.button(src: /button\.png/)).to exist
      expect(browser.button(text: 'Button 2')).to exist
      expect(browser.button(text: /Button 2/)).to exist
      expect(browser.button(class: 'image')).to exist
      expect(browser.button(class: /image/)).to exist
      expect(browser.button(index: 0)).to exist
      expect(browser.button(xpath: "//input[@id='new_user_submit']")).to exist
      expect(browser.button(alt: 'Create a new user')).to exist
      expect(browser.button(alt: /Create a/)).to exist
    end

    it 'returns true if the button exists (tag = :button)' do
      expect(browser.button(name: 'new_user_button_2')).to exist
      expect(browser.button(name: /new_user_button_2/)).to exist
      expect(browser.button(value: 'button_2')).to exist
      expect(browser.button(value: /button_2/)).to exist
      expect(browser.button(text: 'Button 2')).to exist
      expect(browser.button(text: /Button 2/)).to exist
      expect(browser.button(value: 'Button 2')).to exist
      expect(browser.button(value: /Button 2/)).to exist
    end

    it 'returns true if the button exists (how = :caption)' do
      expect {
        expect(browser.button(caption: 'Button 2')).to exist
      }.to have_deprecated_caption

      expect {
        expect(browser.button(caption: /Button 2/)).to exist
      }.to have_deprecated_caption
    end

    it 'returns the first button if given no args' do
      expect(browser.button).to exist
    end

    it 'returns true for element with upper case type' do
      expect(browser.button(id: 'new_user_button_preview')).to exist
    end

    it "returns false if the button doesn't exist" do
      expect(browser.button(id: 'no_such_id')).to_not exist
      expect(browser.button(id: /no_such_id/)).to_not exist
      expect(browser.button(name: 'no_such_name')).to_not exist
      expect(browser.button(name: /no_such_name/)).to_not exist
      expect(browser.button(value: 'no_such_value')).to_not exist
      expect(browser.button(value: /no_such_value/)).to_not exist
      expect(browser.button(src: 'no_such_src')).to_not exist
      expect(browser.button(src: /no_such_src/)).to_not exist
      expect(browser.button(text: 'no_such_text')).to_not exist
      expect(browser.button(text: /no_such_text/)).to_not exist
      expect(browser.button(class: 'no_such_class')).to_not exist
      expect(browser.button(class: /no_such_class/)).to_not exist
      expect(browser.button(index: 1337)).to_not exist
      expect(browser.button(xpath: "//input[@id='no_such_id']")).to_not exist
    end

    it 'checks the tag name and type attribute when locating by xpath' do
      expect(browser.button(xpath: "//input[@type='text']")).to_not exist
      expect(browser.button(xpath: "//input[@type='button']")).to exist
    end

    it 'matches the specific type when locating by type' do
      expect(browser.button(type: 'button').type).to eq 'button'
      expect(browser.button(type: 'reset').type).to eq 'reset'
      expect(browser.button(type: 'submit').type).to eq 'submit'
      expect(browser.button(type: 'image').type).to eq 'image'
    end

    it 'matches valid input types when type is boolean' do
      expect(browser.buttons(type: false).map(&:tag_name)).to all eq('button')

      input_buttons = browser.buttons(type: true).select { |e| e.tag_name == 'input' }
      expect(input_buttons.map(&:type).uniq).to match_array(Watir::Button::VALID_TYPES)
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.button(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  # Attribute methods
  describe '#id' do
    it 'returns the id if the button exists' do
      expect(browser.button(index: 0).id).to eq 'new_user_submit'
      expect(browser.button(index: 1).id).to eq 'new_user_reset'
      expect(browser.button(index: 2).id).to eq 'new_user_button'
    end

    it 'raises UnknownObjectException if button does not exist' do
      expect { browser.button(index: 1337).id }.to raise_unknown_object_exception
    end
  end

  describe '#name' do
    it 'returns the name if button exists' do
      expect(browser.button(index: 0).name).to eq 'new_user_submit'
      expect(browser.button(index: 1).name).to eq 'new_user_reset'
      expect(browser.button(index: 2).name).to eq 'new_user_button'
    end

    it 'raises UnknownObjectException if the button does not exist' do
      expect { browser.button(name: 'no_such_name').name }.to raise_unknown_object_exception
    end
  end

  describe '#src' do
    it 'returns the src attribute for the button image' do
      # varies between browsers
      expect(browser.button(name: 'new_user_image').src).to include('images/button.png')
    end

    it 'raises UnknownObjectException if the button does not exist' do
      expect { browser.button(name: 'no_such_name').src }.to raise_unknown_object_exception
    end
  end

  describe '#style' do
    not_compliant_on :internet_explorer do
      it 'returns the style attribute if the button exists' do
        expect(browser.button(id: 'delete_user_submit').style).to eq 'border: 4px solid red;'
      end
    end

    it "returns an empty string if the element exists and the attribute doesn't exist" do
      expect(browser.button(id: 'new_user_submit').style).to eq ''
    end

    it 'raises UnknownObjectException if the button does not exist' do
      expect { browser.button(name: 'no_such_name').style }.to raise_unknown_object_exception
    end
  end

  describe '#title' do
    it 'returns the title of the button' do
      expect(browser.button(index: 0).title).to eq 'Submit the form'
    end

    it 'returns an empty string for button without title' do
      expect(browser.button(index: 1).title).to eq ''
    end
  end

  describe '#type' do
    it 'returns the type if button exists' do
      expect(browser.button(index: 0).type).to eq 'submit'
      expect(browser.button(index: 1).type).to eq 'reset'
      expect(browser.button(index: 2).type).to eq 'button'
    end

    it 'raises UnknownObjectException if button does not exist' do
      expect { browser.button(name: 'no_such_name').type }.to raise_unknown_object_exception
    end
  end

  describe '#value' do
    it 'returns the value if button exists' do
      expect(browser.button(index: 0).value).to eq 'Submit'
      expect(browser.button(index: 1).value).to eq 'Reset'
      expect(browser.button(index: 2).value).to eq 'Button'
    end

    it 'raises UnknownObjectException if button does not exist' do
      expect { browser.button(name: 'no_such_name').value }.to raise_unknown_object_exception
    end
  end

  describe '#text' do
    it 'returns the text of an input button' do
      expect(browser.button(index: 0).text).to eq 'Submit'
      expect(browser.button(index: 1).text).to eq 'Reset'
      expect(browser.button(index: 2).text).to eq 'Button'
      expect(browser.button(index: 3).text).to eq 'Preview'
    end

    it 'returns the text of a button element' do
      expect(browser.button(name: 'new_user_button_2').text).to eq 'Button 2'
    end

    it 'raises UnknownObjectException if the element does not exist' do
      expect { browser.button(id: 'no_such_id').text }.to raise_unknown_object_exception
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.button(index: 0)).to respond_to(:class_name)
      expect(browser.button(index: 0)).to respond_to(:id)
      expect(browser.button(index: 0)).to respond_to(:name)
      expect(browser.button(index: 0)).to respond_to(:src)
      expect(browser.button(index: 0)).to respond_to(:style)
      expect(browser.button(index: 0)).to respond_to(:title)
      expect(browser.button(index: 0)).to respond_to(:type)
      expect(browser.button(index: 0)).to respond_to(:value)
    end
  end

  # Access methods
  describe '#enabled?' do
    it 'returns true if the button is enabled' do
      expect(browser.button(name: 'new_user_submit')).to be_enabled
    end

    it 'returns false if the button is disabled' do
      expect(browser.button(name: 'new_user_submit_disabled')).to_not be_enabled
    end

    it "raises UnknownObjectException if the button doesn't exist" do
      expect { browser.button(name: 'no_such_name').enabled? }.to raise_unknown_object_exception
    end

    it 'raises ObjectDisabledException if disabled button is clicked' do
      expect { browser.button(name: 'new_user_submit_disabled').click }.to raise_object_disabled_exception
    end
  end

  describe '#disabled?' do
    it 'returns false when button is enabled' do
      expect(browser.button(name: 'new_user_submit')).to_not be_disabled
    end

    it 'returns true when button is disabled' do
      expect(browser.button(name: 'new_user_submit_disabled')).to be_disabled
    end

    it 'raises UnknownObjectException if button does not exist' do
      expect { browser.button(name: 'no_such_name').disabled? }.to raise_unknown_object_exception
    end
  end

  # Manipulation methods
  describe '#click' do
    it 'clicks the button if it exists' do
      browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
      browser.button(id: 'delete_user_submit').click
      Watir::Wait.until { !browser.url.include? 'forms_with_input_elements.html' }
      expect(browser.text).to include('Semantic table')
    end

    it 'fires events' do
      browser.button(id: 'new_user_button').click
      expect(browser.button(id: 'new_user_button').value).to eq 'new_value_set_by_onclick_event'
    end

    it "raises UnknownObjectException when clicking a button that doesn't exist" do
      expect { browser.button(value: 'no_such_value').click }.to raise_unknown_object_exception
      expect { browser.button(id: 'no_such_id').click }.to raise_unknown_object_exception
    end

    it 'raises ObjectDisabledException when clicking a disabled button' do
      expect { browser.button(value: 'Disabled').click }.to raise_object_disabled_exception
    end
  end
end
