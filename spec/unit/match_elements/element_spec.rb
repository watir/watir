require_relative '../unit_helper'

describe Watir::Locators::Element::Matcher do
  include LocatorSpecHelper

  let(:query_scope) { @query_scope || browser }
  let(:values_to_match) { @values_to_match || {} }
  let(:matcher) { described_class.new(query_scope, values_to_match) }

  describe '#match' do
    context 'a label element' do
      it 'returns elements with for / id pairs' do
        input_wds = [wd_element(tag_name: 'input', attributes: {id: 'foob_id'}),
                     wd_element(tag_name: 'input', attributes: {id: 'bfoo_id'}),
                     wd_element(tag_name: 'input', attributes: {id: 'foo_id'})]

        label_wds = [wd_element(tag_name: 'label', text: 'foob'),
                     wd_element(tag_name: 'label', text: 'bfoo'),
                     wd_element(tag_name: 'label', text: 'foo')]

        labels = [element(watir_element: Watir::Label, wd: label_wds[0], for: 'foob_id'),
                  element(watir_element: Watir::Label, wd: label_wds[1], for: 'bfoo_id'),
                  element(watir_element: Watir::Label, wd: label_wds[2], for: 'foo_id')]

        # Only the Watir::Label matching the text provided will have wd called
        expect(labels[0]).not_to receive(:for)
        expect(labels[1]).not_to receive(:for)

        allow(query_scope).to receive(:labels).and_return(labels)
        allow(matcher).to receive(:deprecate_text_regexp).exactly(3).times
        allow_any_instance_of(Watir::Input).to receive(:wd).and_return(input_wds[2], input_wds[2])

        values_to_match = {label_element: 'foo'}

        expect(matcher.match(input_wds, values_to_match, :all)).to eq [input_wds[2]]
      end

      it 'returns elements without for / id pairs' do
        input_wds = [wd_element(tag_name: 'input'),
                     wd_element(tag_name: 'input'),
                     wd_element(tag_name: 'input')]

        inputs = [element(watir_element: Watir::Input, wd: input_wds[0]),
                  element(watir_element: Watir::Input, wd: input_wds[1]),
                  element(watir_element: Watir::Input, wd: input_wds[2])]

        label_wds = [wd_element(tag_name: 'label', text: 'foob'),
                     wd_element(tag_name: 'label', text: 'Foo'),
                     wd_element(tag_name: 'label', text: 'foo')]

        labels = [element(watir_element: Watir::Label, wd: label_wds[0], for: '', input: inputs[0]),
                  element(watir_element: Watir::Label, wd: label_wds[1], for: '', input: inputs[1]),
                  element(watir_element: Watir::Label, wd: label_wds[2], for: '', input: inputs[2])]

        # Only the Watir::Label matching the text provided will have wd called
        expect(labels[0]).not_to receive(:for)
        expect(labels[1]).not_to receive(:for)

        allow(query_scope).to receive(:labels).and_return(labels)
        allow(matcher).to receive(:deprecate_text_regexp).exactly(3).times

        values_to_match = {label_element: 'foo'}

        expect(matcher.match(input_wds, values_to_match, :all)).to eq [input_wds[2]]
      end

      it 'returns elements with multiple matching label text but first missing corresponding element' do
        input_wds = [wd_element(tag_name: 'input'),
                     wd_element(tag_name: 'input')]

        inputs = [element(watir_element: Watir::Input, wd: wd_element(tag_name: 'input')),
                  element(watir_element: Watir::Input, wd: input_wds[1])]

        label_wds = [wd_element(tag_name: 'label', text: 'foo'),
                     wd_element(tag_name: 'label', text: 'foo')]

        labels = [element(watir_element: Watir::Label, wd: label_wds[0], for: '', input: inputs[0]),
                  element(watir_element: Watir::Label, wd: label_wds[1], for: '', input: inputs[1])]

        allow(query_scope).to receive(:labels).and_return(labels)
        allow(matcher).to receive(:deprecate_text_regexp).exactly(2).times

        values_to_match = {label_element: 'foo'}

        expect(matcher.match(input_wds, values_to_match, :all)).to eq [input_wds[1]]
      end

      it 'returns empty Array if no label element matches' do
        input_wds = [wd_element(tag_name: 'input', attributes: {id: 'foo'}),
                     wd_element(tag_name: 'input', attributes: {id: 'bfoo'})]

        label_wds = [wd_element(tag_name: 'label', text: 'Not this'),
                     wd_element(tag_name: 'label', text: 'Or This')]

        labels = [element(watir_element: Watir::Label, wd: label_wds[0], for: 'foo'),
                  element(watir_element: Watir::Label, wd: label_wds[1], for: 'bfoo')]

        allow(query_scope).to receive(:labels).and_return(labels)
        allow(matcher).to receive(:deprecate_text_regexp).exactly(2).times

        values_to_match = {label_element: 'foo'}

        expect(matcher.match(input_wds, values_to_match, :all)).to eq []
      end

      it 'returns empty Array if matching label elements do not have an corresponding input element' do
        input_wds = [wd_element(tag_name: 'input'),
                     wd_element(tag_name: 'input')]

        inputs = [element(watir_element: Watir::Input, wd: wd_element(tag_name: 'input')),
                  element(watir_element: Watir::Input, wd: wd_element(tag_name: 'input'))]

        label_wds = [wd_element(tag_name: 'label', text: 'foob'),
                     wd_element(tag_name: 'label', text: 'foo')]

        labels = [element(watir_element: Watir::Label, wd: label_wds[0], for: '', input: inputs[0]),
                  element(watir_element: Watir::Label, wd: label_wds[1], for: '', input: inputs[1])]

        allow(query_scope).to receive(:labels).and_return(labels)
        allow(matcher).to receive(:deprecate_text_regexp).exactly(2).times

        values_to_match = {label_element: 'foo'}

        expect(matcher.match(input_wds, values_to_match, :all)).to eq []
      end
    end

    context 'when locating one element' do
      before { @filter = :first }

      it 'by tag name' do
        elements = [wd_element(tag_name: 'div'),
                    wd_element(tag_name: 'span')]
        @values_to_match = {tag_name: 'span'}

        expect(matcher.match(elements, values_to_match, @filter)).to eq elements[1]
      end

      it 'by attribute' do
        elements = [wd_element(attributes: {id: 'foo'}),
                    wd_element(attributes: {id: 'bar'}),
                    wd_element(attributes: {id: 'foobar'})]
        @values_to_match = {id: 'foobar'}

        expect(matcher.match(elements, values_to_match, @filter)).to eq elements[2]
      end

      it 'by class array' do
        elements = [wd_element(attributes: {class: 'foob bar'}),
                    wd_element(attributes: {class: 'bar'}),
                    wd_element(attributes: {class: 'bar foo'})]
        @values_to_match = {class: %w[foo bar]}

        expect(matcher.match(elements, values_to_match, @filter)).to eq elements[2]
      end

      it 'by positive index' do
        elements = [wd_element(tag_name: 'div'),
                    wd_element(tag_name: 'span'),
                    wd_element(tag_name: 'div')]

        @values_to_match = {tag_name: 'div', index: 1}

        expect(matcher.match(elements, values_to_match, @filter)).to eq elements[2]
      end

      it 'by negative index' do
        elements = [wd_element(tag_name: 'div'),
                    wd_element(tag_name: 'span'),
                    wd_element(tag_name: 'div')]

        @values_to_match = {tag_name: 'div', index: -1}

        expect(matcher.match(elements.dup, values_to_match, @filter)).to eq elements[2]
      end

      it 'by visibility true' do
        elements = [wd_element(tag_name: 'div', "displayed?": false),
                    wd_element(tag_name: 'span', "displayed?": true)]
        @values_to_match = {visible: true}

        expect(matcher.match(elements, values_to_match, @filter)).to eq elements[1]
      end

      it 'by visibility false' do
        elements = [wd_element(tag_name: 'div', "displayed?": true),
                    wd_element(tag_name: 'span', "displayed?": false)]
        @values_to_match = {visible: false}

        expect(matcher.match(elements, values_to_match, @filter)).to eq elements[1]
      end

      it 'by text' do
        elements = [wd_element(text: 'foo'),
                    wd_element(text: 'Foob')]
        @values_to_match = {text: 'Foob'}

        allow(matcher).to receive(:deprecate_text_regexp).exactly(3).times

        expect(matcher.match(elements, values_to_match, @filter)).to eq elements[1]
      end

      it 'by visible text' do
        elements = [wd_element(text: 'foo'),
                    wd_element(text: 'Foob')]
        @values_to_match = {visible_text: /Foo|Bar/}

        allow(elements[0]).to receive(:text).and_return 'foo'
        allow(elements[1]).to receive(:text).and_return 'Foob'

        expect(matcher.match(elements, values_to_match, @filter)).to eq elements[1]
      end

      it 'by href' do
        elements = [wd_element(tag_name: 'div', attributes: {href: 'froo.com'}),
                    wd_element(tag_name: 'span', attributes: {href: 'bar.com'})]
        @values_to_match = {href: /foo|bar/}

        expect(matcher.match(elements, values_to_match, @filter)).to eq elements[1]
      end

      it "returns nil if found element doesn't match the selector tag_name" do
        elements = [wd_element(tag_name: 'div')]

        @values_to_match = {tag_name: 'span'}

        expect(matcher.match(elements, values_to_match, @filter)).to eq nil
      end
    end

    context 'when locating collection' do
      before { @filter = :all }

      it 'by tag name' do
        elements = [wd_element(tag_name: 'div'),
                    wd_element(tag_name: 'span'),
                    wd_element(tag_name: 'div')]
        @values_to_match = {tag_name: 'div'}

        expect(matcher.match(elements, values_to_match, @filter)).to eq [elements[0], elements[2]]
      end

      it 'by attribute' do
        elements = [wd_element(attributes: {foo: 'foo'}),
                    wd_element(attributes: {foo: 'bar'}),
                    wd_element(attributes: {foo: 'foo'})]
        @values_to_match = {foo: 'foo'}

        expect(matcher.match(elements, values_to_match, @filter)).to eq [elements[0], elements[2]]
      end

      it 'by single class' do
        elements = [wd_element(attributes: {class: 'foo bar cool'}),
                    wd_element(attributes: {class: 'foob bar'}),
                    wd_element(attributes: {class: 'bar foo foobar'})]
        @values_to_match = {class: 'foo'}

        expect(matcher.match(elements, values_to_match, @filter)).to eq [elements[0], elements[2]]
      end

      it 'by class array' do
        elements = [wd_element(attributes: {class: 'foo bar cool'}),
                    wd_element(attributes: {class: 'foob bar'}),
                    wd_element(attributes: {class: 'bar foo foobar'})]
        @values_to_match = {class: %w[foo bar]}

        expect(matcher.match(elements, values_to_match, @filter)).to eq [elements[0], elements[2]]
      end

      it 'by visibility true' do
        elements = [wd_element(tag_name: 'div'),
                    wd_element(tag_name: 'span'),
                    wd_element(tag_name: 'div')]
        @values_to_match = {visible: true}

        allow(elements[0]).to receive(:displayed?).and_return false
        allow(elements[1]).to receive(:displayed?).and_return true
        allow(elements[2]).to receive(:displayed?).and_return true

        expect(matcher.match(elements, values_to_match, @filter)).to eq [elements[1], elements[2]]
      end

      it 'by visibility false' do
        elements = [wd_element("displayed?": false),
                    wd_element("displayed?": true),
                    wd_element("displayed?": false)]
        @values_to_match = {visible: false}

        expect(matcher.match(elements, values_to_match, @filter)).to eq [elements[0], elements[2]]
      end

      it 'by text' do
        elements = [wd_element(text: 'foo'),
                    wd_element(text: 'Foob'),
                    wd_element(text: 'bBarb')]
        @values_to_match = {text: /Foo|Bar/}

        allow(matcher).to receive(:deprecate_text_regexp).exactly(3).times

        expect(matcher.match(elements, values_to_match, @filter)).to eq [elements[1], elements[2]]
      end

      it 'by visible text' do
        elements = [wd_element(text: 'foo'),
                    wd_element(text: 'Foob'),
                    wd_element(text: 'bBarb')]
        @values_to_match = {visible_text: /Foo|Bar/}

        expect(matcher.match(elements, values_to_match, @filter)).to eq [elements[1], elements[2]]
      end

      it 'by href' do
        elements = [wd_element(attributes: {href: 'froo.com'}),
                    wd_element(attributes: {href: 'bar.com'}),
                    wd_element(attributes: {href: 'foobar.com'})]
        @values_to_match = {href: /foo|bar/}

        expect(matcher.match(elements, values_to_match, @filter)).to eq [elements[1], elements[2]]
      end

      it 'returns empty Array if found no element matches the selector tag_name' do
        elements = [wd_element(tag_name: 'div')]

        @values_to_match = {tag_name: 'span'}

        expect(matcher.match(elements, values_to_match, @filter)).to eq []
      end
    end

    context 'when matching Regular Expressions' do
      it 'with tag_name' do
        elements = [wd_element(tag_name: 'div'),
                    wd_element(tag_name: 'span'),
                    wd_element(tag_name: 'div')]
        @values_to_match = {tag_name: /d|q/}

        expect(matcher.match(elements, values_to_match, @filter)).to eq [elements[0], elements[2]]
      end

      it 'with single class' do
        elements = [wd_element(attributes: {class: 'foo bar cool'}),
                    wd_element(attributes: {class: 'foob bar'}),
                    wd_element(attributes: {class: 'bar foo foobar'})]
        @values_to_match = {class: /foob|q/}

        expect(matcher.match(elements, values_to_match, @filter)).to eq [elements[1], elements[2]]
      end

      it 'with multiple classes' do
        elements = [wd_element(attributes: {class: 'foo bar cool'}),
                    wd_element(attributes: {class: 'foob bar'}),
                    wd_element(attributes: {class: 'bar foo foobar'})]
        @values_to_match = {class: [/foob/, /bar/]}

        expect(matcher.match(elements, values_to_match, @filter)).to eq [elements[1], elements[2]]
      end

      it 'with attributes' do
        elements = [wd_element(attributes: {foo: 'foo'}),
                    wd_element(attributes: {foo: 'bar'}),
                    wd_element(attributes: {foo: 'foo'})]
        @values_to_match = {foo: /fo/}

        expect(matcher.match(elements, values_to_match, @filter)).to eq [elements[0], elements[2]]
      end
    end

    # TODO: These should have the same tests for label locators, but the mocking is more complex
    # See equivalent tests in checkbox_spec
    context 'text_regexp deprecations' do
      let(:filter) { :first }
      let(:elements) do
        [wd_element(text: 'all visible'),
         wd_element(text: 'some visible')]
      end

      it 'not thrown when still matched by text content' do
        @values_to_match = {text: /some visible/}
        allow(browser).to receive(:execute_script).and_return('some visible some hidden')

        expect {
          expect(matcher.match(elements, values_to_match, filter)).to eq elements[1]
        }.not_to have_deprecated_text_regexp
      end

      it 'not thrown with complex regexp matched by text content' do
        @values_to_match = {text: /some (in|)visible/}
        allow(browser).to receive(:execute_script).and_return('some visible some hidden')

        expect {
          expect(matcher.match(elements, values_to_match, filter)).to eq elements[1]
        }.not_to have_deprecated_text_regexp
      end

      not_compliant_on :watigiri do
        it 'thrown when no longer matched by text content' do
          @values_to_match = {text: /some visible$/}
          allow(browser).to receive(:execute_script).and_return('some visible some hidden')

          expect {
            expect(matcher.match(elements, values_to_match, filter)).to eq elements[1]
          }.to have_deprecated_text_regexp
        end
      end

      not_compliant_on :watigiri do
        it 'not thrown when element does not exist' do
          @values_to_match = {text: /definitely not there/}

          expect {
            expect(matcher.match(elements, values_to_match, filter)).to eq elements[1]
          }.to_not have_deprecated_text_regexp
        end
      end

      # Note: This will work after:text_regexp deprecation removed
      it 'keeps element from being located' do
        @values_to_match = {text: /some visible some hidden/}

        expect(matcher.match(elements, values_to_match, filter)).to be_nil
      end
    end
  end
end
