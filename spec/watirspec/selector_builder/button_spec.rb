require 'watirspec_helper'

describe Watir::Locators::Button::SelectorBuilder do
  let(:attributes) { Watir::HTMLElement.attribute_list }
  let(:scope_tag_name) { nil }
  let(:selector_builder) { described_class.new(attributes) }
  let(:default_types) do
    "translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='button' or" \
" translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='reset' or"\
" translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='submit' or"\
" translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='image'"
  end

  describe '#build' do
    after(:each) do |example|
      next if example.metadata[:skip_after]

      @query_scope ||= browser
      built = selector_builder.build(@selector)
      expect(built).to eq [@wd_locator, (@remaining || {})]

      next unless @data_locator || @tag_name

      expect { @located = @query_scope.wd.first(@wd_locator) }.not_to raise_exception

      if @data_locator
        expect(@located.attribute('data-locator')).to eq(@data_locator)
      else
        expect {
          expect(@located.tag_name).to eq @tag_name
        }.not_to raise_exception
      end
    end

    it 'without any arguments' do
      browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
      @selector = {}
      @wd_locator = {xpath: ".//*[(local-name()='button') or (local-name()='input' and (#{default_types}))]"}
      @data_locator = 'user submit'
    end

    context 'with type' do
      before(:each) { browser.goto(WatirSpec.url_for('forms_with_input_elements.html')) }

      it 'false only locates with button without a type' do
        @selector = {type: false}
        @wd_locator = {xpath: ".//*[(local-name()='button' and not(@type))]"}
        @data_locator = 'No Type'
      end

      it 'true locates button or input with a type' do
        @selector = {type: true}
        @wd_locator = {xpath: ".//*[(local-name()='button' and @type) or " \
"(local-name()='input' and (#{default_types}))]"}
        @data_locator = 'user submit'
      end

      it 'locates input or button element with specified type' do
        @selector = {type: 'reset'}
        @wd_locator = {xpath: ".//*[(local-name()='button' and " \
"translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='reset') or " \
"(local-name()='input' and (translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='reset'))]"}
        @data_locator = 'reset'
      end

      it 'raises exception when a non-button type input is specified', skip_after: true do
        selector = {type: 'checkbox'}
        msg = 'Button Elements can not be located by input type: checkbox'
        expect { selector_builder.build(selector) }
          .to raise_exception Watir::Exception::LocatorException, msg
      end
    end

    context 'with xpath or css' do
      before(:each) do
        browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
      end

      it 'returns tag name and type to the locator' do
        @selector = {xpath: '#disabled_button', tag_name: 'input', type: 'submit'}
        @wd_locator = {xpath: '#disabled_button'}
        @remaining = {tag_name: 'input', type: 'submit'}
      end
    end

    context 'with text' do
      before(:each) { browser.goto(WatirSpec.url_for('forms_with_input_elements.html')) }

      it 'locates value of input element with String' do
        @selector = {text: 'Button'}
        @wd_locator = {xpath: ".//*[(local-name()='button' and normalize-space()='Button') or " \
"(local-name()='input' and (#{default_types}) and @value='Button')]"}
        @data_locator = 'new user'
      end

      it 'locates text of button element with String' do
        @selector = {text: 'Button 2'}
        @wd_locator = {xpath: ".//*[(local-name()='button' and normalize-space()='Button 2') or " \
"(local-name()='input' and (#{default_types}) and @value='Button 2')]"}
        @data_locator = 'Benjamin'
      end

      it 'locates value of input element with simple Regexp' do
        @selector = {text: /Button/}
        @wd_locator = {xpath: ".//*[(local-name()='button' and contains(text(), 'Button')) or " \
"(local-name()='input' and (#{default_types}) and contains(@value, 'Button'))]"}
        @data_locator = 'new user'
      end

      it 'locates text of button element with simple Regexp' do
        @selector = {text: /Button 2/}
        @wd_locator = {xpath: ".//*[(local-name()='button' and contains(text(), 'Button 2')) or " \
"(local-name()='input' and (#{default_types}) and contains(@value, 'Button 2'))]"}
        @data_locator = 'Benjamin'
      end

      it 'returns complex Regexp to the locator' do
        @selector = {text: /^foo$/}
        @wd_locator = {xpath: ".//*[(local-name()='button' and text()) or " \
"(local-name()='input' and (#{default_types}) and @value)]"}
        @remaining = {text: /^foo$/}
      end
    end

    context 'with value' do
      before(:each) { browser.goto(WatirSpec.url_for('forms_with_input_elements.html')) }

      it 'input element value with String' do
        @selector = {value: 'Preview'}
        @wd_locator = {xpath: ".//*[(local-name()='button') or (local-name()='input' and (#{default_types}))]" \
"[normalize-space()='Preview' or @value='Preview']"}
        @data_locator = 'preview'
      end

      it 'button element value with String' do
        @selector = {value: 'button_2'}
        @wd_locator = {xpath: ".//*[(local-name()='button') or (local-name()='input' and (#{default_types}))]" \
"[normalize-space()='button_2' or @value='button_2']"}
        @data_locator = 'Benjamin'
      end

      it 'input element value with simple Regexp' do
        @selector = {value: /Prev/}
        @wd_locator = {xpath: ".//*[(local-name()='button') or (local-name()='input' and (#{default_types}))]" \
"[contains(text(), 'Prev') or contains(@value, 'Prev')]"}
        @data_locator = 'preview'
      end

      it 'button element value with simple Regexp' do
        @selector = {value: /on_2/}
        @wd_locator = {xpath: ".//*[(local-name()='button') or (local-name()='input' and (#{default_types}))]" \
"[contains(text(), 'on_2') or contains(@value, 'on_2')]"}
        @data_locator = 'Benjamin'
      end

      it 'button element text with String' do
        @selector = {value: 'Button 2'}
        @wd_locator = {xpath: ".//*[(local-name()='button') or (local-name()='input' and (#{default_types}))]" \
"[normalize-space()='Button 2' or @value='Button 2']"}
        @data_locator = 'Benjamin'
      end

      it 'button element text with simple Regexp' do
        @selector = {value: /ton 2/}
        @wd_locator = {xpath: ".//*[(local-name()='button') or (local-name()='input' and (#{default_types}))]" \
"[contains(text(), 'ton 2') or contains(@value, 'ton 2')]"}
        @data_locator = 'Benjamin'
      end

      it 'returns complex Regexp to the locator' do
        @selector = {value: /^foo$/}
        @wd_locator = {xpath: ".//*[(local-name()='button') or (local-name()='input' and (#{default_types}))]" \
'[text() or @value]'}
        @remaining = {value: /^foo$/}
      end
    end

    context 'with multiple locators' do
      before(:each) do
        browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
      end

      it 'locates using class and attributes' do
        @selector = {class: 'image', name: 'new_user_image', src: true}
        @wd_locator = {xpath: ".//*[(local-name()='button') or (local-name()='input' and (#{default_types}))]" \
"[contains(concat(' ', @class, ' '), ' image ')][@name='new_user_image' and @src]"}
        @data_locator = 'submittable button'
      end
    end

    it 'delegates adjacent to Element SelectorBuilder' do
      browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
      @query_scope = browser.element(id: 'new_user_button').locate

      @selector = {adjacent: :ancestor, index: 2}
      @wd_locator = {xpath: './ancestor::*[3]'}
      @data_locator = 'body'
    end
  end
end
