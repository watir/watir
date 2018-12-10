require 'watirspec_helper'

describe 'SelectList' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  # Exists method
  describe '#exists?' do
    it 'returns true if the select list exists' do
      expect(browser.select_list(id: 'new_user_country')).to exist
      expect(browser.select_list(id: /new_user_country/)).to exist
      expect(browser.select_list(name: 'new_user_country')).to exist
      expect(browser.select_list(name: /new_user_country/)).to exist
      expect(browser.select_list(class: 'country')).to exist
      expect(browser.select_list(class: /country/)).to exist
      expect(browser.select_list(index: 0)).to exist
      expect(browser.select_list(xpath: "//select[@id='new_user_country']")).to exist
    end

    it 'returns the first select if given no args' do
      expect(browser.select_list).to exist
    end

    it "returns false if the select list doesn't exist" do
      expect(browser.select_list(id: 'no_such_id')).to_not exist
      expect(browser.select_list(id: /no_such_id/)).to_not exist
      expect(browser.select_list(name: 'no_such_name')).to_not exist
      expect(browser.select_list(name: /no_such_name/)).to_not exist
      expect(browser.select_list(value: 'no_such_value')).to_not exist
      expect(browser.select_list(value: /no_such_value/)).to_not exist
      expect(browser.select_list(text: 'no_such_text')).to_not exist
      expect(browser.select_list(text: /no_such_text/)).to_not exist
      expect(browser.select_list(class: 'no_such_class')).to_not exist
      expect(browser.select_list(class: /no_such_class/)).to_not exist
      expect(browser.select_list(index: 1337)).to_not exist
      expect(browser.select_list(xpath: "//select[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.select_list(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  # Attribute methods
  describe '#id' do
    it 'returns the id of the element' do
      expect(browser.select_list(index: 0).id).to eq 'new_user_country'
    end

    it "raises UnknownObjectException if the select list doesn't exist" do
      expect { browser.select_list(index: 1337).id }.to raise_unknown_object_exception
    end
  end

  describe '#name' do
    it 'returns the name of the element' do
      expect(browser.select_list(index: 0).name).to eq 'new_user_country'
    end

    it "raises UnknownObjectException if the select list doesn't exist" do
      expect { browser.select_list(index: 1337).name }.to raise_unknown_object_exception
    end
  end

  describe '#multiple?' do
    it 'knows whether the select list allows multiple selections' do
      expect(browser.select_list(index: 0)).to_not be_multiple
      expect(browser.select_list(index: 1)).to be_multiple
    end

    it "raises UnknownObjectException if the select list doesn't exist" do
      expect { browser.select_list(index: 1337).multiple? }.to raise_unknown_object_exception
    end
  end

  describe '#value' do
    not_compliant_on :safari do
      it 'returns the value of the selected option' do
        expect(browser.select_list(index: 0).value).to eq '2'
        browser.select_list(index: 0).select(/Sweden/)
        expect(browser.select_list(index: 0).value).to eq '3'
      end
    end

    it "raises UnknownObjectException if the select list doesn't exist" do
      expect { browser.select_list(index: 1337).value }.to raise_unknown_object_exception
    end
  end

  describe '#text' do
    not_compliant_on :safari do
      it 'returns the text of the selected option' do
        expect(browser.select_list(index: 0).text).to eq 'Norway'
        browser.select_list(index: 0).select(/Sweden/)
        expect(browser.select_list(index: 0).text).to eq 'Sweden'
      end

      it "raises UnknownObjectException if the select list doesn't exist" do
        expect { browser.select_list(index: 1337).text }.to raise_unknown_object_exception
      end
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.select_list(index: 0)).to respond_to(:class_name)
      expect(browser.select_list(index: 0)).to respond_to(:id)
      expect(browser.select_list(index: 0)).to respond_to(:name)
      expect(browser.select_list(index: 0)).to respond_to(:value)
    end
  end

  # Access methods
  describe '#enabled?' do
    it 'returns true if the select list is enabled' do
      expect(browser.select_list(name: 'new_user_country')).to be_enabled
    end

    it 'returns false if the select list is disabled' do
      expect(browser.select_list(name: 'new_user_role')).to_not be_enabled
    end

    it "raises UnknownObjectException if the select_list doesn't exist" do
      expect { browser.select_list(name: 'no_such_name').enabled? }.to raise_unknown_object_exception
    end
  end

  describe '#disabled?' do
    it 'returns true if the select list is disabled' do
      expect(browser.select_list(index: 2)).to be_disabled
    end

    it 'returns false if the select list is enabled' do
      expect(browser.select_list(index: 0)).to_not be_disabled
    end

    it 'should raise UnknownObjectException when the select list does not exist' do
      expect { browser.select_list(index: 1337).disabled? }.to raise_unknown_object_exception
    end
  end

  # Other
  describe '#option' do
    it 'returns an instance of Option' do
      option = browser.select_list(name: 'new_user_country').option(text: 'Denmark')
      expect(option).to be_instance_of(Watir::Option)
      expect(option.value).to eq '1'
    end
  end

  describe '#options' do
    it 'returns all the options' do
      options = browser.select_list(name: 'new_user_country').options
      expect(options.map(&:text)).to eq ['Denmark', 'Norway', 'Sweden', 'United Kingdom', 'USA', 'Germany']
    end
  end

  describe '#selected_options' do
    it "should raise UnknownObjectException if the select list doesn't exist" do
      expect { browser.select_list(name: 'no_such_name').selected_options }.to raise_unknown_object_exception
    end

    it 'gets the currently selected item(s)' do
      expect(browser.select_list(name: 'new_user_country').selected_options.map(&:text)).to eq ['Norway']
      expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq %w[EN NO]
    end
  end

  describe '#clear' do
    not_compliant_on :safari do
      it 'clears the selection when possible' do
        browser.select_list(name: 'new_user_languages').clear
        expect(browser.select_list(name: 'new_user_languages').selected_options).to be_empty
      end
    end

    it 'does not clear selections if the select list does not allow multiple selections' do
      expect {
        browser.select_list(name: 'new_user_country').clear
      }.to raise_error(/you can only clear multi-selects/)

      expect(browser.select_list(name: 'new_user_country').selected_options.map(&:text)).to eq ['Norway']
    end

    it "raises UnknownObjectException if the select list doesn't exist" do
      expect { browser.select_list(name: 'no_such_name').clear }.to raise_unknown_object_exception
    end

    not_compliant_on :safari do
      it 'fires onchange event' do
        browser.select_list(name: 'new_user_languages').clear
        expect(messages.size).to eq 2
      end

      it "doesn't fire onchange event for already cleared option" do
        browser.select_list(name: 'new_user_languages').option.clear
        expect(messages.size).to eq 0
      end
    end
  end

  describe '#include?' do
    it 'returns true if the given option exists by text' do
      expect(browser.select_list(name: 'new_user_country')).to include('Denmark')
    end

    it 'returns true if the given option exists by label' do
      expect(browser.select_list(name: 'new_user_country')).to include('Germany')
    end

    it "returns false if the given option doesn't exist" do
      expect(browser.select_list(name: 'new_user_country')).to_not include('Ireland')
    end
  end

  not_compliant_on :safari do
    describe '#selected?' do
      it 'returns true if the given option is selected by text' do
        browser.select_list(name: 'new_user_country').select('Denmark')
        expect(browser.select_list(name: 'new_user_country')).to be_selected('Denmark')
      end

      it 'returns false if the given option is not selected by text' do
        expect(browser.select_list(name: 'new_user_country')).to_not be_selected('Sweden')
      end

      it 'returns true if the given option is selected by label' do
        browser.select_list(name: 'new_user_country').select('Germany')
        expect(browser.select_list(name: 'new_user_country')).to be_selected('Germany')
      end

      it 'returns false if the given option is not selected by label' do
        expect(browser.select_list(name: 'new_user_country')).to_not be_selected('Germany')
      end

      it "raises UnknownObjectException if the option doesn't exist" do
        expect { browser.select_list(name: 'new_user_country').selected?('missing_option') }
          .to raise_unknown_object_exception
      end
    end
  end

  describe '#select' do
    context 'when finding by value' do
      it 'selects an option with a String' do
        browser.select_list(name: 'new_user_languages').clear
        browser.select_list(name: 'new_user_languages').select('2')
        expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq %w[EN]
      end

      it 'selects an option with a Regexp' do
        browser.select_list(name: 'new_user_languages').clear
        expect { browser.select_list(name: 'new_user_languages').select(/1|3/) }.to have_deprecated_select_by
        expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq %w[Danish NO]
      end
    end

    context 'when finding by text' do
      it 'selects an option with a String' do
        browser.select_list(name: 'new_user_country').select('Denmark')
        expect(browser.select_list(name: 'new_user_country').selected_options.map(&:text)).to eq ['Denmark']
      end

      it 'selects an option with a Regexp' do
        browser.select_list(name: 'new_user_country').select(/Denmark/)
        expect(browser.select_list(name: 'new_user_country').selected_options.map(&:text)).to eq ['Denmark']
      end
    end

    context 'when finding by label' do
      it 'selects an option with a String' do
        browser.select_list(name: 'new_user_languages').clear
        browser.select_list(name: 'new_user_languages').select('NO')
        expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq ['NO']
      end

      it 'selects an option with a Regexp' do
        browser.select_list(name: 'new_user_languages').clear
        browser.select_list(name: 'new_user_languages').select(/^N/)
        expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq ['NO']
      end
    end

    it 'selects multiple options successiveley' do
      browser.select_list(name: 'new_user_languages').clear
      browser.select_list(name: 'new_user_languages').select('Danish')
      browser.select_list(name: 'new_user_languages').select('Swedish')
      expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq %w[Danish Swedish]
    end

    it 'selects each item in an Array' do
      browser.select_list(name: 'new_user_languages').clear
      browser.select_list(name: 'new_user_languages').select(%w[Danish Swedish])
      expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq %w[Danish Swedish]
    end

    it 'selects each item in a parameter list' do
      browser.select_list(name: 'new_user_languages').clear
      browser.select_list(name: 'new_user_languages').select('Danish', 'Swedish')
      expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq %w[Danish Swedish]
    end

    bug 'https://bugzilla.mozilla.org/show_bug.cgi?id=1255957', :firefox do
      it 'selects empty options' do
        browser.select_list(id: 'delete_user_username').select('')
        expect(browser.select_list(id: 'delete_user_username').selected_options.map(&:text)).to eq ['']
      end
    end

    it 'returns the value selected' do
      expect(browser.select_list(name: 'new_user_languages').select('Danish')).to eq 'Danish'
    end

    not_compliant_on :safari do
      it 'fires onchange event when selecting an item' do
        browser.select_list(id: 'new_user_languages').select('Danish')
        expect(messages).to eq ['changed language']
      end

      it "doesn't fire onchange event when selecting an already selected item" do
        browser.select_list(id: 'new_user_languages').clear # removes the two pre-selected options
        browser.select_list(id: 'new_user_languages').select('English')
        expect(messages.size).to eq 3

        browser.select_list(id: 'new_user_languages').select('English')
        expect(messages.size).to eq 3
      end

      it 'returns an empty string when selecting an option that disappears when selected' do
        expect(browser.select_list(id: 'obsolete').select('sweden')).to eq ''
      end
    end

    it 'selects options with a single-quoted value' do
      browser.select_list(id: 'single-quote').select("'foo'")
    end

    compliant_on :relaxed_locate do
      it 'waits to select an option' do
        browser.goto WatirSpec.url_for('wait.html')
        browser.a(id: 'add_select').click
        select_list = browser.select_list(id: 'languages')
        expect { select_list.select('No') }.to wait_and_raise_no_value_found_exception
      end
    end

    it "raises NoValueFoundException if the option doesn't exist" do
      message = /#<Watir::Select: located: false; {:name=>"new_user_country", :tag_name=>"select"}>/
      expect { browser.select_list(name: 'new_user_country').select('missing_option') }
        .to raise_no_value_found_exception message
      expect { browser.select_list(name: 'new_user_country').select(/missing_option/) }
        .to raise_no_value_found_exception message
    end

    it 'raises ObjectDisabledException if the option is disabled' do
      expect { browser.select_list(name: 'new_user_languages').select('Russian') }
        .to raise_object_disabled_exception
    end

    it 'raises a TypeError if argument is not a String, Regexp or Numeric' do
      expect { browser.select_list(id: 'new_user_languages').select({}) }.to raise_error(TypeError)
    end
  end

  describe '#select!' do
    context 'when finding by value' do
      it 'selects an option with a String' do
        browser.select_list(name: 'new_user_languages').clear
        browser.select_list(name: 'new_user_languages').select!('2')
        expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq %w[EN]
      end

      it 'selects an option with a Regex' do
        browser.select_list(name: 'new_user_languages').clear
        browser.select_list(name: 'new_user_languages').select!(/2/)
        expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq %w[EN]
      end
    end

    context 'when finding by text' do
      it 'selects an option with a String' do
        browser.select_list(name: 'new_user_country').select!('Denmark')
        expect(browser.select_list(name: 'new_user_country').selected_options.map(&:text)).to eq ['Denmark']
      end

      it 'selects an option with a Regexp' do
        browser.select_list(name: 'new_user_country').select!(/Denmark/)
        expect(browser.select_list(name: 'new_user_country').selected_options.map(&:text)).to eq ['Denmark']
      end
    end

    context 'when finding by label' do
      it 'selects an option with a String' do
        browser.select_list(name: 'new_user_languages').clear
        browser.select_list(name: 'new_user_languages').select!('NO')
        expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq ['NO']
      end

      it 'selects an option with a Regexp' do
        browser.select_list(name: 'new_user_languages').clear
        browser.select_list(name: 'new_user_languages').select!(/NO/)
        expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq ['NO']
      end
    end

    it 'selects multiple items successively' do
      browser.select_list(name: 'new_user_languages').clear
      browser.select_list(name: 'new_user_languages').select!('Danish')
      browser.select_list(name: 'new_user_languages').select!('Swedish')
      expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq %w[Danish Swedish]
    end

    it 'selects each item in an Array' do
      browser.select_list(name: 'new_user_languages').clear
      browser.select_list(name: 'new_user_languages').select!(%w[Danish Swedish])
      expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq %w[Danish Swedish]
    end

    it 'selects each item in a parameter list' do
      browser.select_list(name: 'new_user_languages').clear
      browser.select_list(name: 'new_user_languages').select!('Danish', 'Swedish')
      expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq %w[Danish Swedish]
    end

    bug 'https://bugzilla.mozilla.org/show_bug.cgi?id=1255957', :firefox do
      it 'selects empty options' do
        browser.select_list(id: 'delete_user_username').select!('')
        expect(browser.select_list(id: 'delete_user_username').selected_options.map(&:text)).to eq ['']
      end
    end

    it 'returns the value selected' do
      browser.select_list(name: 'new_user_languages').clear
      expect(browser.select_list(name: 'new_user_languages').select!('Danish')).to eq 'Danish'
    end

    it 'selects options with a single-quoted value' do
      browser.select_list(id: 'single-quote').select!("'foo'")
    end

    it 'selects exact matches when using String' do
      browser.select_list(name: 'new_user_languages').clear
      browser.select_list(name: 'new_user_languages').select!('Latin')
      selected_options = browser.select_list(name: 'new_user_languages').selected_options.map(&:text)
      expect(selected_options).not_to include('Azeri - Latin')
      expect(selected_options).to include('Latin')
    end

    it "raises NoValueFoundException if the option doesn't exist" do
      expect { browser.select_list(id: 'new_user_country').select!('missing_option') }
        .to raise_no_value_found_exception
      expect { browser.select_list(id: 'new_user_country').select!(/missing_option/) }
        .to raise_no_value_found_exception
    end

    it 'raises ObjectDisabledException if the option is disabled' do
      browser.select_list(id: 'new_user_languages').clear
      expect { browser.select_list(id: 'new_user_languages').select!('Russian') }
        .to raise_object_disabled_exception
    end

    it 'raises a TypeError if argument is not a String, Regexp or Numeric' do
      browser.select_list(id: 'new_user_languages').clear
      expect { browser.select_list(id: 'new_user_languages').select!({}) }.to raise_error(TypeError)
    end
  end

  describe '#select_all' do
    it 'selects multiple options based on text' do
      browser.select_list(name: 'new_user_languages').clear
      browser.select_list(name: 'new_user_languages').select_all(/ish/)
      list = %w[Danish EN Swedish]
      expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq list
    end

    it 'selects multiple options based on labels' do
      browser.select_list(name: 'new_user_languages').clear
      browser.select_list(name: 'new_user_languages').select_all(/NO|EN/)
      list = %w[EN NO]
      expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq list
    end

    it 'selects all options in an Array' do
      browser.select_list(name: 'new_user_languages').clear
      browser.select_list(name: 'new_user_languages').select_all([/ish/, /Latin/])
      list = ['Danish', 'EN', 'Swedish', 'Azeri - Latin', 'Latin']
      expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq list
    end

    it 'selects all options in a parameter list' do
      browser.select_list(name: 'new_user_languages').clear
      browser.select_list(name: 'new_user_languages').select_all(/ish/, /Latin/)
      list = ['Danish', 'EN', 'Swedish', 'Azeri - Latin', 'Latin']
      expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq list
    end

    it 'returns the first matching value if there are multiple matches' do
      expect(browser.select_list(name: 'new_user_languages').select_all(/ish/)).to eq 'Danish'
    end
  end

  describe '#select_all!' do
    it 'selects multiple options based on value' do
      browser.select_list(name: 'new_user_languages').clear
      browser.select_list(name: 'new_user_languages').select_all!(/\d+/)
      list = %w[Danish EN NO Russian]
      expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq list
    end

    it 'selects multiple options based on text' do
      browser.select_list(name: 'new_user_languages').clear
      browser.select_list(name: 'new_user_languages').select_all!(/ish/)
      list = %w[Danish EN Swedish]
      expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq list
    end

    it 'selects multiple options based on labels' do
      browser.select_list(name: 'new_user_languages').clear
      browser.select_list(name: 'new_user_languages').select_all!(/NO|EN/)
      list = %w[EN NO]
      expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq list
    end

    it 'selects all options in an Array' do
      browser.select_list(name: 'new_user_languages').clear
      browser.select_list(name: 'new_user_languages').select_all!([/ish/, /Latin/])
      list = ['Danish', 'EN', 'Swedish', 'Azeri - Latin', 'Latin']
      expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq list
    end

    it 'selects all options in a parameter list' do
      browser.select_list(name: 'new_user_languages').clear
      browser.select_list(name: 'new_user_languages').select_all!(/ish/, /Latin/)
      list = ['Danish', 'EN', 'Swedish', 'Azeri - Latin', 'Latin']
      expect(browser.select_list(name: 'new_user_languages').selected_options.map(&:text)).to eq list
    end

    it 'returns the first matching value if there are multiple matches' do
      expect(browser.select_list(name: 'new_user_languages').select_all!(/ish/)).to eq 'Danish'
    end
  end

  # deprecate?
  not_compliant_on :safari do
    describe '#select_value' do
    end
  end
end
