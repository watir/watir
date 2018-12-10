require_relative '../unit_helper'

describe Watir::Locators::TextField::SelectorBuilder do
  include LocatorSpecHelper

  let(:selector_builder) { described_class.new(attributes, query_scope) }
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
    it 'without any arguments' do
      selector = {}
      built = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]"}

      expect(selector_builder.build(selector)).to eq built
    end

    context 'with type' do
      it 'specified text field type that is text' do
        selector = {type: 'text'}
        built = {xpath: ".//*[local-name()='input']" \
"[translate(@type,'#{uppercase}','#{lowercase}')='text']"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'specified text field type that is not text' do
        selector = {type: 'number'}
        built = {xpath: ".//*[local-name()='input']" \
"[translate(@type,'#{uppercase}','#{lowercase}')='number']"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'true locates text field with a type specified' do
        selector = {type: true}
        built = {xpath: ".//*[local-name()='input'][#{negative_types}]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'false locates text field without type specified' do
        selector = {type: false}
        built = {xpath: ".//*[local-name()='input'][not(@type)]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'raises exception when a non-text field type input is specified' do
        selector = {type: 'checkbox'}
        msg = 'TextField Elements can not be located by type: checkbox'

        expect { selector_builder.build(selector) }
          .to raise_exception Watir::Exception::LocatorException, msg
      end
    end

    context 'with index' do
      it 'positive' do
        selector = {index: 4}
        built = {xpath: "(.//*[local-name()='input'][not(@type) or (#{negative_types})])[5]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'negative' do
        selector = {index: -3}
        built = {xpath: "(.//*[local-name()='input'][not(@type) or (#{negative_types})])[last()-2]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'last' do
        selector = {index: -1}
        built = {xpath: "(.//*[local-name()='input'][not(@type) or (#{negative_types})])[last()]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'does not return index if it is zero' do
        selector = {index: 0}
        built = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'raises exception when index is not an Integer' do
        selector = {index: 'foo'}
        msg = /expected one of \[(Integer|Fixnum)\], got "foo":String/

        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end
    end

    context 'with wrong tag name' do
      # TODO: Should this throw exception?
      it 'ignores tag name' do
        selector = {tag_name: 'div'}
        built = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]"}

        expect(selector_builder.build(selector)).to eq built
      end
    end

    context 'with text' do
      it 'String for value' do
        selector = {text: 'Developer'}
        built = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]", text: 'Developer'}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'Simple Regexp for value' do
        selector = {text: /Dev/}
        built = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]", text: /Dev/}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'returns complicated Regexp to the locator as a value' do
        selector = {text: /^foo$/}
        built = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]", text: /^foo$/}

        expect(selector_builder.build(selector)).to eq built
      end
    end

    context 'with label' do
      it 'using String' do
        selector = {label: 'First name'}
        built = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]" \
"[@id=//label[normalize-space()='First name']/@for or parent::label[normalize-space()='First name']]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'uses String with hidden text' do
        selector = {label: 'With hidden text'}
        built = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]" \
"[@id=//label[normalize-space()='With hidden text']/@for or parent::label[normalize-space()='With hidden text']]"}

        expect(selector_builder.build(selector)).to eq built
      end

      # TODO: Can use contains once remove :text_regexp deprecation
      xit 'using simple Regexp' do
        selector = {label: /First/}
        built = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]" \
"[@id=//label[contains(text(), 'First')]/@for or parent::label[contains(text(), 'First')]]"}

        expect(selector_builder.build(selector)).to eq built
      end

      # TODO: Can use contains once remove :text_regexp deprecation
      xit 'using complex Regexp' do
        selector = {label: /([qa])st? name/}
        built = {xpath: ".//*[local-name()='input'][not(@type) or (#{negative_types})]" \
"[@id=//label[contains(text(), 's') and contains(text(), ' name')]/@for or " \
"parent::label[contains(text(), 's') and contains(text(), ' name')]]", label_element: /([qa])st? name/}

        expect(selector_builder.build(selector)).to eq built
      end
    end

    context 'with multiple locators' do
      it 'locates using tag name, class, attributes and text' do
        selector = {text: 'Developer', class: /c/, id: true}
        built = {xpath: ".//*[local-name()='input'][contains(@class, 'c')]" \
"[not(@type) or (#{negative_types})][@id]", text: 'Developer'}

        expect(selector_builder.build(selector)).to eq built
      end
    end
  end
end
