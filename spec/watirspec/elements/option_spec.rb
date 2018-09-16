require 'watirspec_helper'

describe 'Option' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  describe '#exists?' do
    it 'returns true if the element exists (page context)' do
      expect(browser.option(id: 'nor')).to exist
      expect(browser.option(id: /nor/)).to exist
      expect(browser.option(value: '2')).to exist
      expect(browser.option(value: /2/)).to exist
      expect(browser.option(text: 'Norway')).to exist
      expect(browser.option(text: /Norway/)).to exist
      expect(browser.option(class: 'scandinavia')).to exist
      expect(browser.option(index: 1)).to exist
      expect(browser.option(xpath: "//option[@id='nor']")).to exist
    end

    it 'returns the first option if given no args' do
      expect(browser.option).to exist
    end

    it 'returns true if the element exists (select_list context)' do
      expect(browser.select_list(name: 'new_user_country').option(id: 'nor')).to exist
      expect(browser.select_list(name: 'new_user_country').option(id: /nor/)).to exist
      expect(browser.select_list(name: 'new_user_country').option(value: '2')).to exist
      expect(browser.select_list(name: 'new_user_country').option(value: /2/)).to exist
      expect(browser.select_list(name: 'new_user_country').option(text: 'Norway')).to exist
      expect(browser.select_list(name: 'new_user_country').option(text: /Norway/)).to exist
      expect(browser.select_list(name: 'new_user_country').option(class: 'scandinavia')).to exist
      expect(browser.select_list(name: 'new_user_country').option(index: 1)).to exist
      expect(browser.select_list(name: 'new_user_country').option(xpath: "//option[@id='nor']")).to exist
      expect(browser.select_list(name: 'new_user_country').option(label: 'Germany')).to exist
    end

    it 'returns false if the element does not exist (page context)' do
      expect(browser.option(id: 'no_such_id')).to_not exist
      expect(browser.option(id: /no_such_id/)).to_not exist
      expect(browser.option(value: 'no_such_value')).to_not exist
      expect(browser.option(value: /no_such_value/)).to_not exist
      expect(browser.option(text: 'no_such_text')).to_not exist
      expect(browser.option(text: /no_such_text/)).to_not exist
      expect(browser.option(class: 'no_such_class')).to_not exist
      expect(browser.option(index: 1337)).to_not exist
      expect(browser.option(xpath: "//option[@id='no_such_id']")).to_not exist
    end

    it 'returns false if the element does not exist (select_list context)' do
      expect(browser.select_list(name: 'new_user_country').option(id: 'no_such_id')).to_not exist
      expect(browser.select_list(name: 'new_user_country').option(id: /no_such_id/)).to_not exist
      expect(browser.select_list(name: 'new_user_country').option(value: 'no_such_value')).to_not exist
      expect(browser.select_list(name: 'new_user_country').option(value: /no_such_value/)).to_not exist
      expect(browser.select_list(name: 'new_user_country').option(text: 'no_such_text')).to_not exist
      expect(browser.select_list(name: 'new_user_country').option(text: /no_such_text/)).to_not exist
      expect(browser.select_list(name: 'new_user_country').option(class: 'no_such_class')).to_not exist
      expect(browser.select_list(name: 'new_user_country').option(index: 1337)).to_not exist
      expect(browser.select_list(name: 'new_user_country').option(xpath: "//option[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.option(id: 3.14).exists? }.to raise_error(TypeError)
      expect { browser.select_list(name: 'new_user_country').option(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  describe '#select' do
    not_compliant_on :safari do
      it 'selects the chosen option (page context)' do
        browser.option(text: 'Denmark').select
        expect(browser.select_list(name: 'new_user_country').selected_options.map(&:text)).to eq ['Denmark']
      end

      it 'selects the chosen option (select_list context)' do
        browser.select_list(name: 'new_user_country').option(text: 'Denmark').select
        expect(browser.select_list(name: 'new_user_country').selected_options.map(&:text)).to eq ['Denmark']
      end

      it 'selects the option when found by text (page context)' do
        browser.option(text: 'Sweden').select
        expect(browser.option(text: 'Sweden')).to be_selected
      end

      it 'selects the option when found by text (select_list context)' do
        browser.select_list(name: 'new_user_country').option(text: 'Sweden').select
        expect(browser.select_list(name: 'new_user_country').option(text: 'Sweden')).to be_selected
      end
    end

    it 'raises UnknownObjectException if the option does not exist (page context)' do
      expect { browser.option(text: 'no_such_text').select }.to raise_unknown_object_exception
      expect { browser.option(text: /missing/).select }.to raise_unknown_object_exception
    end

    it 'raises UnknownObjectException if the option does not exist (select_list context)' do
      expect { browser.select_list(name: 'new_user_country').option(text: 'no_such_text').select }
        .to raise_unknown_object_exception
      expect { browser.select_list(name: 'new_user_country').option(text: /missing/).select }
        .to raise_unknown_object_exception
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.select_list(name: 'new_user_country').option(text: 'Sweden')).to respond_to(:class_name)
      expect(browser.select_list(name: 'new_user_country').option(text: 'Sweden')).to respond_to(:id)
      expect(browser.select_list(name: 'new_user_country').option(text: 'Sweden')).to respond_to(:text)
    end
  end
end
