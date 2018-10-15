require 'watirspec_helper'

describe Watir::Locators::TextField::SelectorBuilder do
  let(:attributes) { Watir::HTMLElement.attribute_list }
  let(:scope_tag_name) { nil }
  let(:selector_builder) { described_class.new(attributes) }
  let(:negative_types) do
    "translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!='file' and "\
"translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!='radio' and " \
"translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!='checkbox' and " \
"translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!='submit' and " \
"translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!='reset' and " \
"translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!='image' and " \
"translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!='button' and " \
"translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!='hidden' and " \
"translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!='range' and " \
"translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!='color' and " \
"translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!='date' and " \
"translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')!='datetime-local'"
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
      @wd_locator = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]"}
      @data_locator = 'input name'
    end

    context 'with type' do
      before(:each) { browser.goto(WatirSpec.url_for('forms_with_input_elements.html')) }

      it 'specified text field type that is text' do
        @selector = {type: 'text'}
        @wd_locator = {xpath: ".//*[local-name()='input']" \
"[translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='text']"}
        @data_locator = 'first text'
      end

      it 'specified text field type that is not text' do
        @selector = {type: 'number'}
        @wd_locator = {xpath: ".//*[local-name()='input']" \
"[translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='number']"}
        @data_locator = '42'
      end

      it 'true locates text field with a type specified' do
        @selector = {type: true}
        @wd_locator = {xpath: ".//*[local-name()='input'][#{negative_types}]"}
        @data_locator = 'input name'
      end

      it 'false locates text field without type specified' do
        @selector = {type: false}
        @wd_locator = {xpath: ".//*[local-name()='input'][not(@type)]"}
        @data_locator = 'input name'
      end

      it 'raises exception when a non-text field type input is specified', skip_after: true do
        selector = {type: 'checkbox'}
        msg = 'TextField Elements can not be located by type: checkbox'
        expect { selector_builder.build(selector) }
          .to raise_exception Watir::Exception::LocatorException, msg
      end
    end

    context 'with text' do
      before(:each) { browser.goto(WatirSpec.url_for('forms_with_input_elements.html')) }

      it 'String for value' do
        @selector = {text: 'Developer'}
        @wd_locator = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]"}
        @remaining = {text: 'Developer'}
      end

      it 'Simple Regexp for value' do
        @selector = {text: /Dev/}
        @wd_locator = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]"}
        @remaining = {text: /Dev/}
      end

      it 'returns complicated Regexp to the locator as a value' do
        @selector = {text: /^foo$/}
        @wd_locator = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]"}
        @remaining = {text: /^foo$/}
      end
    end

    context 'with multiple locators' do
      before(:each) do
        browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
      end

      it 'locates using tag name, class, attributes and text' do
        @selector = {text: 'Developer', class: /c/, id: true}
        @wd_locator = {xpath: ".//*[local-name()='input'][contains(@class, 'c')]" \
"[not(@type) or (#{negative_types})][@id]"}
        @remaining = {text: 'Developer'}
      end

      it 'delegates adjacent to Element SelectorBuilder' do
        browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
        @query_scope = browser.element(id: 'new_user_email').locate

        @selector = {adjacent: :ancestor, index: 1}
        @wd_locator = {xpath: './ancestor::*[2]'}
        @data_locator = 'form'
      end
    end
  end
end
