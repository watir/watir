require 'watirspec_helper'

describe Watir::Locators::TextField::SelectorBuilder do
  let(:attributes) { Watir::HTMLElement.attribute_list }
  let(:scope_tag_name) { nil }
  let(:selector_builder) { described_class.new(attributes) }
  let(:uppercase) { 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ' }
  let(:lowercase) { 'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ' }
  let(:negative_types) do
    "translate(@type,'#{uppercase}','#{lowercase}')!='file' and "\
"translate(@type,'#{uppercase}','#{lowercase}')!='radio' and " \
"translate(@type,'#{uppercase}','#{lowercase}')!='checkbox' and " \
"translate(@type,'#{uppercase}','#{lowercase}')!='submit' and " \
"translate(@type,'#{uppercase}','#{lowercase}')!='reset' and " \
"translate(@type,'#{uppercase}','#{lowercase}')!='image' and " \
"translate(@type,'#{uppercase}','#{lowercase}')!='button' and " \
"translate(@type,'#{uppercase}','#{lowercase}')!='hidden' and " \
"translate(@type,'#{uppercase}','#{lowercase}')!='range' and " \
"translate(@type,'#{uppercase}','#{lowercase}')!='color' and " \
"translate(@type,'#{uppercase}','#{lowercase}')!='date' and " \
"translate(@type,'#{uppercase}','#{lowercase}')!='datetime-local'"
  end

  describe '#build' do
    after(:each) do |example|
      next if example.metadata[:skip_after]

      @query_scope ||= browser

      expect(selector_builder.build(@selector)).to eq @built

      next unless @data_locator || @tag_name

      expect { @located = @query_scope.wd.first(@built) }.not_to raise_exception

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
      @built = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]"}
      @data_locator = 'input name'
    end

    context 'with type' do
      before(:each) { browser.goto(WatirSpec.url_for('forms_with_input_elements.html')) }

      it 'specified text field type that is text' do
        @selector = {type: 'text'}
        @built = {xpath: ".//*[local-name()='input']" \
"[translate(@type,'#{uppercase}','#{lowercase}')='text']"}
        @data_locator = 'first text'
      end

      it 'specified text field type that is not text' do
        @selector = {type: 'number'}
        @built = {xpath: ".//*[local-name()='input']" \
"[translate(@type,'#{uppercase}','#{lowercase}')='number']"}
        @data_locator = '42'
      end

      it 'true locates text field with a type specified' do
        @selector = {type: true}
        @built = {xpath: ".//*[local-name()='input'][#{negative_types}]"}
        @data_locator = 'input name'
      end

      it 'false locates text field without type specified' do
        @selector = {type: false}
        @built = {xpath: ".//*[local-name()='input'][not(@type)]"}
        @data_locator = 'input name'
      end

      it 'raises exception when a non-text field type input is specified', skip_after: true do
        selector = {type: 'checkbox'}
        msg = 'TextField Elements can not be located by type: checkbox'
        expect { selector_builder.build(selector) }
          .to raise_exception Watir::Exception::LocatorException, msg
      end
    end

    context 'with index' do
      before(:each) do
        browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
      end

      it 'positive' do
        @selector = {index: 4}
        @built = {xpath: "(.//*[local-name()='input'][not(@type) or (#{negative_types})])[5]"}
        @data_locator = 'dev'
      end

      it 'negative' do
        @selector = {index: -3}
        @built = {xpath: "(.//*[local-name()='input'][not(@type) or (#{negative_types})])[last()-2]"}
        @data_locator = '42'
      end

      it 'last' do
        @selector = {index: -1}
        @built = {xpath: "(.//*[local-name()='input'][not(@type) or (#{negative_types})])[last()]"}
        @data_locator = 'last text'
      end

      it 'does not return index if it is zero' do
        @selector = {index: 0}
        @built = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]"}
        @data_locator = 'input name'
      end

      it 'raises exception when index is not an Integer', skip_after: true do
        selector = {index: 'foo'}
        msg = /expected one of \[(Integer|Fixnum)\], got "foo":String/
        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end
    end

    context 'with text' do
      before(:each) { browser.goto(WatirSpec.url_for('forms_with_input_elements.html')) }

      it 'String for value' do
        @selector = {text: 'Developer'}
        @built = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]", text: 'Developer'}
      end

      it 'Simple Regexp for value' do
        @selector = {text: /Dev/}
        @built = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]", text: /Dev/}
      end

      it 'returns complicated Regexp to the locator as a value' do
        @selector = {text: /^foo$/}
        @built = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]", text: /^foo$/}
      end
    end

    context 'with label' do
      before(:each) { browser.goto(WatirSpec.url_for('forms_with_input_elements.html')) }

      it 'using String' do
        @selector = {label: 'First name'}
        @built = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]" \
"[@id=//label[normalize-space()='First name']/@for or parent::label[normalize-space()='First name']]"}
        @data_locator = 'input name'
      end

      it 'uses String with hidden text' do
        @selector = {label: 'With hidden text'}
        @built = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]" \
"[@id=//label[normalize-space()='With hidden text']/@for or parent::label[normalize-space()='With hidden text']]"}
        @data_locator = 'hidden'
      end

      # Desired Behavior
      xit 'using simple Regexp' do
        @selector = {label: /First/}
        @built = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]" \
"[@id=//label[contains(text(), 'First')]/@for or parent::label[contains(text(), 'First')]]"}
        @data_locator = 'input name'
      end

      # Desired Behavior
      xit 'using complex Regexp' do
        @selector = {label: /([qa])st? name/}
        @built = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]" \
"[@id=//label[contains(text(), 's') and contains(text(), ' name')]/@for or " \
"parent::label[contains(text(), 's') and contains(text(), ' name')]]", label_element: /([qa])st? name/}
      end
    end

    context 'with multiple locators' do
      before(:each) do
        browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
      end

      it 'locates using tag name, class, attributes and text' do
        @selector = {text: 'Developer', class: /c/, id: true}
        @built = {xpath: ".//*[local-name()='input'][contains(@class, 'c')]" \
"[not(@type) or (#{negative_types})][@id]", text: 'Developer'}
      end

      it 'delegates adjacent to Element SelectorBuilder' do
        browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
        @query_scope = browser.element(id: 'new_user_email').locate

        @selector = {adjacent: :ancestor, index: 1}
        @built = {xpath: './ancestor::*[2]'}
        @data_locator = 'form'
      end
    end
  end
end
