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
      @wd_locator = {xpath: ".//*[local-name()='button' or (local-name()='input' and #{default_types})]"}
      @data_locator = 'user submit'
    end

    context 'with type' do
      before(:each) { browser.goto(WatirSpec.url_for('forms_with_input_elements.html')) }

      it 'false locates button elements' do
        @selector = {type: false}
        @wd_locator = {xpath: ".//*[local-name()='button']"}
        @data_locator = 'Benjamin'
      end

      it 'true locates input elements' do
        @selector = {type: true}
        @wd_locator = {xpath: ".//*[(local-name()='input' and #{default_types})]"}
        @data_locator = 'user submit'
      end

      it 'locates input element with specified type' do
        @selector = {type: 'reset'}
        reset_only = "translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='reset'"
        @wd_locator = {xpath: ".//*[(local-name()='input' and #{reset_only})]"}
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

      it 'String for text' do
        @selector = {text: 'Button 2'}
        @wd_locator = {xpath: ".//*[local-name()='button' or (local-name()='input' and #{default_types})]" \
"[normalize-space()='Button 2' or @value='Button 2']"}
        @data_locator = 'Benjamin'
      end

      it 'Simple Regexp for value' do
        @selector = {text: /Prev/}
        @wd_locator = {xpath: ".//*[local-name()='button' or (local-name()='input' and #{default_types})]" \
"[contains(text(), 'Prev') or contains(@value, 'Prev')]"}
        @data_locator = 'preview'
      end

      it 'returns complicated Regexp to the locator' do
        @selector = {text: /^foo$/}
        @wd_locator = {xpath: ".//*[local-name()='button' or (local-name()='input' and #{default_types})]"}
        @remaining = {text: /^foo$/}
      end
    end

    context 'with value' do
      before(:each) { browser.goto(WatirSpec.url_for('forms_with_input_elements.html')) }

      it 'String for value' do
        @selector = {value: 'Preview'}
        @wd_locator = {xpath: ".//*[local-name()='button' or (local-name()='input' and #{default_types})]" \
"[normalize-space()='Preview' or @value='Preview']"}
        @data_locator = 'preview'
      end

      it 'Simple Regexp for text' do
        @selector = {value: /2/}
        @wd_locator = {xpath: ".//*[local-name()='button' or (local-name()='input' and #{default_types})]" \
"[contains(text(), '2') or contains(@value, '2')]"}
        @data_locator = 'Benjamin'
      end
    end

    context 'with multiple locators' do
      before(:each) do
        browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
      end

      it 'locates using class and attributes' do
        @selector = {class: 'image', name: 'new_user_image', src: true}
        @wd_locator = {xpath: ".//*[local-name()='button' or (local-name()='input' and #{default_types})]" \
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
