require_relative '../unit_helper'

describe Watir::Locators::Button::SelectorBuilder do
  include LocatorSpecHelper

  let(:selector_builder) { described_class.new(attributes, query_scope) }
  let(:uppercase) { 'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ' }
  let(:lowercase) { 'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ' }
  let(:default_types) do
    "translate(@type,'#{uppercase}','#{lowercase}')='button' or" \
" translate(@type,'#{uppercase}','#{lowercase}')='reset' or"\
" translate(@type,'#{uppercase}','#{lowercase}')='submit' or"\
" translate(@type,'#{uppercase}','#{lowercase}')='image'"
  end

  describe '#build' do
    it 'without any arguments' do
      selector = {}
      built = {xpath: ".//*[(local-name()='button') or (local-name()='input' and (#{default_types}))]"}
      expect(selector_builder.build(selector)).to eq built
    end

    context 'with type' do
      it 'false only locates with button without a type' do
        selector = {type: false}
        built = {xpath: ".//*[(local-name()='button' and not(@type))]"}
        expect(selector_builder.build(selector)).to eq built
      end

      it 'true locates button or input with a type' do
        selector = {type: true}
        built = {xpath: ".//*[(local-name()='button' and @type) or " \
"(local-name()='input' and (#{default_types}))]"}
        expect(selector_builder.build(selector)).to eq built
      end

      it 'locates input or button element with specified type' do
        selector = {type: 'reset'}
        built = {xpath: ".//*[(local-name()='button' and " \
"translate(@type,'#{uppercase}','#{lowercase}')='reset') or " \
"(local-name()='input' and (translate(@type,'#{uppercase}','#{lowercase}')='reset'))]"}
        expect(selector_builder.build(selector)).to eq built
      end

      it 'raises exception when a non-button type input is specified' do
        selector = {type: 'checkbox'}
        msg = 'Button Elements can not be located by input type: checkbox'
        expect { selector_builder.build(selector) }
          .to raise_exception Watir::Exception::LocatorException, msg
      end
    end

    context 'with xpath or css' do
      it 'returns tag name and type to the locator' do
        selector = {xpath: '#disabled_button', tag_name: 'input', type: 'submit'}
        built = {xpath: '#disabled_button', tag_name: 'input', type: 'submit'}
        expect(selector_builder.build(selector)).to eq built
      end
    end

    context 'with text' do
      it 'locates value of input element with String' do
        selector = {text: 'Button'}
        built = {xpath: ".//*[(local-name()='button' and normalize-space()='Button') or " \
"(local-name()='input' and (#{default_types}) and @value='Button')]"}
        expect(selector_builder.build(selector)).to eq built
      end

      it 'locates text of button element with String' do
        selector = {text: 'Button 2'}
        built = {xpath: ".//*[(local-name()='button' and normalize-space()='Button 2') or " \
"(local-name()='input' and (#{default_types}) and @value='Button 2')]"}
        expect(selector_builder.build(selector)).to eq built
      end

      it 'locates value of input element with simple Regexp' do
        selector = {text: /Button/}
        built = {xpath: ".//*[(local-name()='button' and contains(text(), 'Button')) or " \
"(local-name()='input' and (#{default_types}) and contains(@value, 'Button'))]"}
        expect(selector_builder.build(selector)).to eq built
      end

      it 'locates text of button element with simple Regexp' do
        selector = {text: /Button 2/}
        built = {xpath: ".//*[(local-name()='button' and contains(text(), 'Button 2')) or " \
"(local-name()='input' and (#{default_types}) and contains(@value, 'Button 2'))]"}
        expect(selector_builder.build(selector)).to eq built
      end

      it 'Simple Regexp for text' do
        selector = {text: /n 2/}
        built = {xpath: ".//*[(local-name()='button' and contains(text(), 'n 2')) or " \
"(local-name()='input' and (#{default_types}) and contains(@value, 'n 2'))]"}
        expect(selector_builder.build(selector)).to eq built
      end

      it 'Simple Regexp for value' do
        selector = {text: /Prev/}
        built = {xpath: ".//*[(local-name()='button' and contains(text(), 'Prev')) or " \
"(local-name()='input' and (#{default_types}) and contains(@value, 'Prev'))]"}
        expect(selector_builder.build(selector)).to eq built
      end

      it 'returns complex Regexp to the locator' do
        selector = {text: /^foo$/}
        built = {xpath: ".//*[(local-name()='button' and contains(text(), 'foo')) or " \
"(local-name()='input' and (#{default_types}) and contains(@value, 'foo'))]", text: /^foo$/}
        expect(selector_builder.build(selector)).to eq built
      end
    end

    context 'with value' do
      it 'input element value with String' do
        selector = {value: 'Preview'}
        built = {xpath: ".//*[(local-name()='button') or (local-name()='input' and (#{default_types}))]" \
"[normalize-space()='Preview' or @value='Preview']"}
        expect(selector_builder.build(selector)).to eq built
      end

      it 'button element value with String' do
        selector = {value: 'button_2'}
        built = {xpath: ".//*[(local-name()='button') or (local-name()='input' and (#{default_types}))]" \
"[normalize-space()='button_2' or @value='button_2']"}
        expect(selector_builder.build(selector)).to eq built
      end

      it 'input element value with simple Regexp' do
        selector = {value: /Prev/}
        built = {xpath: ".//*[(local-name()='button') or (local-name()='input' and (#{default_types}))]" \
"[contains(text(), 'Prev') or contains(@value, 'Prev')]"}
        expect(selector_builder.build(selector)).to eq built
      end

      it 'button element value with simple Regexp' do
        selector = {value: /on_2/}
        built = {xpath: ".//*[(local-name()='button') or (local-name()='input' and (#{default_types}))]" \
"[contains(text(), 'on_2') or contains(@value, 'on_2')]"}
        expect(selector_builder.build(selector)).to eq built
      end

      it 'button element text with String' do
        selector = {value: 'Button 2'}
        built = {xpath: ".//*[(local-name()='button') or (local-name()='input' and (#{default_types}))]" \
"[normalize-space()='Button 2' or @value='Button 2']"}
        expect(selector_builder.build(selector)).to eq built
      end

      it 'button element text with simple Regexp' do
        selector = {value: /ton 2/}
        built = {xpath: ".//*[(local-name()='button') or (local-name()='input' and (#{default_types}))]" \
"[contains(text(), 'ton 2') or contains(@value, 'ton 2')]"}
        expect(selector_builder.build(selector)).to eq built
      end

      it 'returns complex Regexp to the locator' do
        selector = {value: /^foo$/}
        built = {xpath: ".//*[(local-name()='button') or (local-name()='input' and (#{default_types}))]" \
"[contains(text(), 'foo') or contains(@value, 'foo')]", value: /^foo$/}
        expect(selector_builder.build(selector)).to eq built
      end
    end

    context 'with index' do
      it 'positive' do
        selector = {index: 3}
        built = {xpath: "(.//*[(local-name()='button') or (local-name()='input' and (#{default_types}))])[4]"}
        expect(selector_builder.build(selector)).to eq built
      end

      it 'negative' do
        selector = {index: -4}
        built = {xpath: "(.//*[(local-name()='button') or " \
"(local-name()='input' and (#{default_types}))])[last()-3]"}
        expect(selector_builder.build(selector)).to eq built
      end

      it 'last' do
        selector = {index: -1}
        built = {xpath: "(.//*[(local-name()='button') or " \
"(local-name()='input' and (#{default_types}))])[last()]"}
        expect(selector_builder.build(selector)).to eq built
      end

      it 'does not return index if it is zero' do
        selector = {index: 0}
        built = {xpath: ".//*[(local-name()='button') or (local-name()='input' and (#{default_types}))]"}
        expect(selector_builder.build(selector)).to eq built
      end

      it 'raises exception when index is not an Integer', skip_after: true do
        selector = {index: 'foo'}
        msg = /expected one of \[(Integer|Fixnum)\], got "foo":String/
        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end
    end

    context 'with multiple locators' do
      it 'locates using class and attributes' do
        selector = {class: 'image', name: 'new_user_image', src: true}
        built = {xpath: ".//*[(local-name()='button') or (local-name()='input' and (#{default_types}))]" \
"[contains(concat(' ', @class, ' '), ' image ')][@name='new_user_image' and @src]"}
        expect(selector_builder.build(selector)).to eq built
      end
    end
  end
end
