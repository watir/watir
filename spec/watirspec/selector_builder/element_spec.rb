require 'watirspec_helper'

describe Watir::Locators::Element::SelectorBuilder do
  let(:selector_builder) { described_class.new(@attributes) }

  describe '#build' do
    after(:each) do |example|
      next if example.metadata[:skip_after]

      @attributes ||= Watir::HTMLElement.attribute_list
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
      @selector = {}
      @built = {xpath: './/*'}
      @tag_name = 'html'
    end

    context 'with xpath or css' do
      before(:each) do
        browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
      end

      it 'locates with xpath only' do
        @selector = {xpath: './/div'}
        @built = @selector.dup
        @data_locator = 'first div'
      end

      it 'locates with css only' do
        @selector = {css: 'div'}
        @built = @selector.dup
        @data_locator = 'first div'
      end

      it 'locates when attributes combined with xpath' do
        @selector = {xpath: './/div', random: 'foo'}
        @built = @selector.dup
        @data_locator = 'first div'
      end

      it 'locates when attributes combined with css' do
        @selector = {css: 'div', random: 'foo'}
        @built = @selector.dup
        @data_locator = 'first div'
      end

      it 'raises exception when using xpath & css', skip_after: true do
        selector = {xpath: './/*', css: 'div'}
        msg = ':xpath and :css cannot be combined ({:xpath=>".//*", :css=>"div"})'
        expect { selector_builder.build(selector) }.to raise_exception Watir::Exception::LocatorException, msg
      end

      it 'raises exception when not a String', skip_after: true do
        selector = {xpath: 7}
        msg = /expected one of \[String\], got 7:(Fixnum|Integer)/
        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end

      xcontext 'Ideal Behavior' do
        it 'xpath' do
          selector = {xpath: ".//*[@id='foo']", tag_name: 'div'}
          expected = {xpath: ".//*[local-name()='div'][@id='foo']"}

          expect_built(selector, expected)
        end

        it 'css' do
          selector = {css: '.bar', tag_name: 'div'}
          expected = {css: 'div.bar'}

          expect_built(selector, expected)
        end
      end
    end

    context 'with tag_name' do
      before(:each) do
        browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
      end

      it 'with String equals' do
        @selector = {tag_name: 'div'}
        @built = {xpath: ".//*[local-name()='div']"}
        @data_locator = 'first div'
      end

      it 'with simple Regexp contains' do
        @selector = {tag_name: /div/}
        @built = {xpath: ".//*[contains(local-name(), 'div')]"}
        @data_locator = 'first div'
      end

      it 'with Symbol' do
        @selector = {tag_name: :div}
        @built = {xpath: ".//*[local-name()='div']"}
        @data_locator = 'first div'
      end

      it 'raises exception when not a String or Regexp', skip_after: true do
        selector = {tag_name: 7}
        msg = /expected one of \[String, Regexp, Symbol\], got 7:(Fixnum|Integer)/
        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end
    end

    context 'with class names' do
      before(:each) do
        browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
      end

      it 'class_name is converted to class' do
        @selector = {class_name: 'user'}
        @built = {xpath: ".//*[contains(concat(' ', @class, ' '), ' user ')]"}
        @data_locator = 'form'
      end

      # TODO: This functionality is deprecated with "class_array"
      it 'values with spaces' do
        @selector = {class_name: 'multiple classes here'}
        @built = {xpath: ".//*[contains(concat(' ', @class, ' '), ' multiple classes here ')]"}
        @data_locator = 'first div'
      end

      it 'single String concatenates' do
        @selector = {class: 'user'}
        @built = {xpath: ".//*[contains(concat(' ', @class, ' '), ' user ')]"}
        @data_locator = 'form'
      end

      it 'Array of String concatenates with and' do
        @selector = {class: %w[multiple here]}
        @built = {xpath: ".//*[contains(concat(' ', @class, ' '), ' multiple ') and " \
"contains(concat(' ', @class, ' '), ' here ')]"}
        @data_locator = 'first div'
      end

      it 'simple Regexp contains' do
        @selector = {class_name: /use/}
        @built = {xpath: ".//*[contains(@class, 'use')]"}
        @data_locator = 'form'
      end

      it 'Array of Regexp contains with and' do
        @selector = {class: [/mult/, /her/]}
        @built = {xpath: ".//*[contains(@class, 'mult') and contains(@class, 'her')]"}
        @data_locator = 'first div'
      end

      it 'single negated String concatenates with not' do
        @selector = {class: '!multiple'}
        @built = {xpath: ".//*[not(contains(concat(' ', @class, ' '), ' multiple '))]"}
        @tag_name = 'html'
      end

      it 'single Boolean true provides the at' do
        @selector = {class: true}
        @built = {xpath: './/*[@class]'}
        @data_locator = 'first div'
      end

      it 'single Boolean false provides the not atat' do
        @selector = {class: false}
        @built = {xpath: './/*[not(@class)]'}
        @tag_name = 'html'
      end

      it 'Array of mixed String, Regexp and Boolean contains and concatenates with and and not' do
        @selector = {class: [/mult/, 'classes', '!here']}
        @built = {xpath: ".//*[contains(@class, 'mult') and contains(concat(' ', @class, ' '), ' classes ') " \
"and not(contains(concat(' ', @class, ' '), ' here '))]"}
        @data_locator = 'second div'
      end

      it 'raises exception when not a String or Regexp or Array', skip_after: true do
        selector = {class: 7}
        msg = /expected one of \[String, Regexp, TrueClass, FalseClass\], got 7:(Fixnum|Integer)/
        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end

      it 'raises exception when Array values are not a String or Regexp', skip_after: true do
        selector = {class: [7]}
        msg = /expected one of \[String, Regexp, TrueClass, FalseClass\], got 7:(Fixnum|Integer)/
        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end

      it 'raises exception when class and class_name are both used', skip_after: true do
        selector = {class: 'foo', class_name: 'bar'}
        msg = 'Can not use both :class and :class_name locators'
        expect { selector_builder.build(selector) }.to raise_exception Watir::Exception::LocatorException, msg
      end

      it 'raises exception when class array is empty', skip_after: true do
        selector = {class: []}
        msg = 'Can not locate elements with an empty Array for :class'
        expect { selector_builder.build(selector) }.to raise_exception Watir::Exception::LocatorException, msg
      end
    end

    context 'with attributes as predicates' do
      before(:each) do
        browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
      end

      it 'with href attribute' do
        @selector = {href: 'watirspec.css'}
        @built = {xpath: ".//*[normalize-space(@href)='watirspec.css']"}
        @data_locator = 'link'
      end

      it 'with string attribute' do
        @selector = {'name' => 'user_new'}
        @built = {xpath: ".//*[@name='user_new']"}
        @data_locator = 'form'
      end

      it 'with String equals' do
        @selector = {name: 'user_new'}
        @built = {xpath: ".//*[@name='user_new']"}
        @data_locator = 'form'
      end

      it 'with TrueClass no equals' do
        @selector = {tag_name: 'input', name: true}
        @built = {xpath: ".//*[local-name()='input'][@name]"}
        @data_locator = 'input name'
      end

      it 'with FalseClass not with no equals' do
        @selector = {tag_name: 'input', name: false}
        @built = {xpath: ".//*[local-name()='input'][not(@name)]"}
        @data_locator = 'input nameless'
      end

      it 'with multiple attributes: no equals and not with no equals and equals' do
        @selector = {readonly: true, foo: false, id: 'good_luck'}
        @built = {xpath: ".//*[@readonly and not(@foo) and @id='good_luck']"}
        @data_locator = 'Good Luck'
      end

      it 'raises exception when attribute value is not a Boolean, String or Regexp', skip_after: true do
        selector = {foo: 7}
        msg = /expected one of \[String, Regexp, TrueClass, FalseClass\], got 7:(Fixnum|Integer)/
        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end

      it 'raises exception when attribute key is not a String or Regexp', skip_after: true do
        selector = {7 => 'foo'}
        msg = /Unable to build XPath using 7:(Fixnum|Integer)/
        expect { selector_builder.build(selector) }.to raise_exception Watir::Exception::LocatorException, msg
      end
    end

    context 'with attributes as partials' do
      before(:each) do
        browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
      end

      it 'with Regexp' do
        @selector = {name: /user/}
        @built = {xpath: ".//*[contains(@name, 'user')]"}
        @data_locator = 'form'
      end

      it 'with multiple Regexp attributes separated by and' do
        @selector = {readonly: /read/, id: /good/}
        @built = {xpath: ".//*[contains(@readonly, 'read') and contains(@id, 'good')]"}
        @data_locator = 'Good Luck'
      end
    end

    context 'with text' do
      before(:each) do
        browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
      end

      it 'String uses normalize space equals' do
        @selector = {text: 'Add user'}
        @built = {xpath: ".//*[normalize-space()='Add user']"}
        @data_locator = 'add user'
      end

      # Deprecated with :caption
      it 'with caption attribute' do
        @selector = {caption: 'Add user'}
        @built = {xpath: ".//*[normalize-space()='Add user']"}
        @data_locator = 'add user'
      end

      it 'raises exception when text is not a String or Regexp', skip_after: true do
        selector = {text: 7}
        msg = /expected one of \[String, Regexp\], got 7:(Fixnum|Integer)/
        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end
    end

    context 'with index' do
      before(:each) do
        browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
      end

      it 'positive' do
        @selector = {tag_name: 'div', index: 7}
        @built = {xpath: "(.//*[local-name()='div'])[8]"}
        @data_locator = 'content'
      end

      it 'negative' do
        @selector = {tag_name: 'div', index: -7}
        @built = {xpath: "(.//*[local-name()='div'])[last()-6]"}
        @data_locator = 'second div'
      end

      it 'last' do
        @selector = {tag_name: 'div', index: -1}
        @built = {xpath: "(.//*[local-name()='div'])[last()]"}
        @data_locator = 'content'
      end

      it 'does not return index if it is zero' do
        @selector = {tag_name: 'div', index: 0}
        @built = {xpath: ".//*[local-name()='div']"}
      end

      it 'raises exception when index is not an Integer', skip_after: true do
        selector = {index: 'foo'}
        msg = /expected one of \[(Integer|Fixnum)\], got "foo":String/
        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end
    end

    context 'with labels' do
      before(:each) do
        browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
      end

      it 'locates the element associated with the label element located by the text of the provided label key' do
        @selector = {label: 'Cars'}
        @built = {xpath: ".//*[@id=//label[normalize-space()='Cars']/@for "\
"or parent::label[normalize-space()='Cars']]"}
        @data_locator = 'cars'
      end

      it 'does not use the label element when label is a valid attribute' do
        @attributes ||= Watir::Option.attribute_list

        @selector = {tag_name: 'option', label: 'Germany'}
        @built = {xpath: ".//*[local-name()='option'][@label='Germany']"}
        @data_locator = 'Berliner'
      end
    end

    context 'with adjacent locators' do
      before(:each) do
        browser.goto(WatirSpec.url_for('nested_elements.html'))
      end

      it 'raises exception when not a Symbol', skip_after: true do
        selector = {adjacent: 'foo', index: 0}
        msg = 'expected one of [Symbol], got "foo":String'
        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end

      it 'raises exception when not a valid value', skip_after: true do
        selector = {adjacent: :foo, index: 0}
        msg = 'Unable to process adjacent locator with foo'
        expect { selector_builder.build(selector) }.to raise_exception Watir::Exception::LocatorException, msg
      end

      describe '#parent' do
        it 'with no other arguments' do
          @query_scope = browser.div(id: 'first_sibling')
          @selector = {adjacent: :ancestor, index: 0}
          @built = {xpath: './ancestor::*[1]'}
          @data_locator = 'parent'
        end

        it 'with index' do
          @query_scope = browser.div(id: 'first_sibling')
          @selector = {adjacent: :ancestor, index: 2}
          @built = {xpath: './ancestor::*[3]'}
          @data_locator = 'grandparent'
        end

        it 'with multiple locators' do
          @query_scope = browser.div(id: 'first_sibling')
          @selector = {adjacent: :ancestor, id: true, tag_name: 'div', class: 'ancestor', index: 1}
          @built = {xpath: "./ancestor::*[local-name()='div']"\
"[contains(concat(' ', @class, ' '), ' ancestor ')][@id][2]"}
          @data_locator = 'grandparent'
        end

        it 'raises an exception if text locator is used', skip_after: true do
          selector = {adjacent: :ancestor, index: 0, text: 'Foo'}
          msg = 'Can not find parent element with text locator'
          expect { selector_builder.build(selector) }
            .to raise_exception Watir::Exception::LocatorException, msg
        end
      end

      describe '#following_sibling' do
        it 'with no other arguments' do
          @query_scope = browser.div(id: 'first_sibling')
          @selector = {adjacent: :following, index: 0}
          @built = {xpath: './following-sibling::*[1]'}
          @data_locator = 'between_siblings1'
        end

        it 'with index' do
          @query_scope = browser.div(id: 'first_sibling')
          @selector = {adjacent: :following, index: 2}
          @built = {xpath: './following-sibling::*[3]'}
          @data_locator = 'between_siblings2'
        end

        it 'with multiple locators' do
          @query_scope = browser.div(id: 'first_sibling')
          @selector = {adjacent: :following, tag_name: 'div', class: 'b', index: 0, id: true}
          @built = {xpath: "./following-sibling::*[local-name()='div']"\
"[contains(concat(' ', @class, ' '), ' b ')][@id][1]"}
          @data_locator = 'second_sibling'
        end

        it 'with text' do
          @query_scope = browser.div(id: 'first_sibling')
          @selector = {adjacent: :following, text: 'Third', index: 0}
          @built = {xpath: "./following-sibling::*[normalize-space()='Third'][1]"}
          @data_locator = 'third_sibling'
        end
      end

      describe '#previous_sibling' do
        it 'with no other arguments' do
          @query_scope = browser.div(id: 'third_sibling')
          @selector = {adjacent: :preceding, index: 0}
          @built = {xpath: './preceding-sibling::*[1]'}
          @data_locator = 'between_siblings2'
        end

        it 'with index' do
          @query_scope = browser.div(id: 'third_sibling')
          @selector = {adjacent: :preceding, index: 2}
          @built = {xpath: './preceding-sibling::*[3]'}
          @data_locator = 'between_siblings1'
        end

        it 'with multiple locators' do
          @query_scope = browser.div(id: 'third_sibling')
          @selector = {adjacent: :preceding, tag_name: 'div', class: 'b', id: true, index: 0}
          @built = {xpath: "./preceding-sibling::*[local-name()='div']"\
"[contains(concat(' ', @class, ' '), ' b ')][@id][1]"}
          @data_locator = 'second_sibling'
        end

        it 'with text' do
          @query_scope = browser.div(id: 'third_sibling')
          @selector = {adjacent: :preceding, text: 'Second', index: 0}
          @built = {xpath: "./preceding-sibling::*[normalize-space()='Second'][1]"}
          @data_locator = 'second_sibling'
        end
      end

      describe '#child' do
        it 'with no other arguments' do
          @query_scope = browser.div(id: 'first_sibling')
          @selector = {adjacent: :child, index: 0}
          @built = {xpath: './child::*[1]'}
          @data_locator = 'child span'
        end

        it 'with index' do
          @query_scope = browser.div(id: 'parent')
          @selector = {adjacent: :child, index: 2}
          @built = {xpath: './child::*[3]'}
          @data_locator = 'second_sibling'
        end

        it 'with multiple locators' do
          @query_scope = browser.div(id: 'parent')
          @selector = {adjacent: :child, tag_name: 'div', class: 'b', id: true, index: 0}
          @built = {xpath: "./child::*[local-name()='div']"\
"[contains(concat(' ', @class, ' '), ' b ')][@id][1]"}
          @data_locator = 'second_sibling'
        end

        it 'with text' do
          @query_scope = browser.div(id: 'parent')
          @selector = {adjacent: :child, text: 'Second', index: 0}
          @built = {xpath: "./child::*[normalize-space()='Second'][1]"}
          @data_locator = 'second_sibling'
        end
      end
    end

    context 'with multiple locators' do
      before(:each) do
        browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
      end

      it 'locates using tag name, class, attributes and text' do
        @selector = {tag_name: 'div', class: 'content', contenteditable: 'true', text: 'Foo'}
        @built = {xpath: ".//*[local-name()='div'][contains(concat(' ', @class, ' '), ' content ')]" \
"[normalize-space()='Foo'][@contenteditable='true']"}
        @data_locator = 'content'
      end
    end

    context 'with simple Regexp' do
      before(:each) do
        browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
      end

      it 'handles spaces' do
        @selector = {title: /od Lu/}
        @built = {xpath: ".//*[contains(@title, 'od Lu')]"}
        @data_locator = 'Good Luck'
      end

      it 'handles escaped characters' do
        @selector = {src: /ages\/but/}
        @built = {xpath: ".//*[contains(@src, 'ages/but')]"}
        @data_locator = 'submittable button'
      end
    end

    context 'with complex Regexp' do
      before(:each) do
        browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
      end

      it 'handles wildcards' do
        @selector = {src: /ages.*but/}
        @built = {xpath: ".//*[contains(@src, 'ages') and contains(@src, 'but')]", src: /ages.*but/}
        @data_locator = 'submittable button'
      end

      it 'handles optional characters' do
        @selector = {src: /ages ?but/}
        @built = {xpath: ".//*[contains(@src, 'ages') and contains(@src, 'but')]", src: /ages ?but/}
        @data_locator = 'submittable button'
      end

      it 'handles anchors' do
        @selector = {name: /^new_user_image$/}
        @built = {xpath: ".//*[contains(@name, 'new_user_image')]", name: /^new_user_image$/}
        @data_locator = 'submittable button'
      end

      it 'handles beginning anchor' do
        @selector = {src: /^i/}
        @built = {xpath: ".//*[starts-with(@src, 'i')]"}
        @data_locator = 'submittable button'
      end

      it 'does not use starts-with if visible locator used' do
        @selector = {id: /^vis/, visible_text: 'shown div'}
        @built = {xpath: ".//*[contains(@id, 'vis')]", id: /^vis/, visible_text: 'shown div'}
      end

      it 'handles case insensitive' do
        @selector = {action: /me/i}
        @built = {xpath: './/*[contains(translate(@action,' \
"'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ'," \
"'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ'), 'me')]"}
        @data_locator = 'form'
      end
    end

    # TODO: These can be moved to unit tests since no browser required
    context 'returns locators that can not be directly translated' do
      it 'attribute with complicated Regexp at end' do
        @selector = {action: /me$/}
        @built = {xpath: ".//*[contains(@action, 'me')]", action: /me$/}
      end

      it 'class with complicated Regexp' do
        @selector = {class: /he?r/}
        @built = {xpath: ".//*[contains(@class, 'h') and contains(@class, 'r')]", class: [/he?r/]}
      end

      it 'text with any Regexp' do
        @selector = {text: /Add/}
        @built = {xpath: './/*', text: /Add/}
      end

      it 'visible' do
        @selector = {tag_name: 'div', visible: true}
        @built = {xpath: ".//*[local-name()='div']", visible: true}
      end

      it 'not visible' do
        @selector = {tag_name: 'span', visible: false}
        @built = {xpath: ".//*[local-name()='span']", visible: false}
      end

      it 'visible text' do
        @selector = {tag_name: 'span', visible_text: 'foo'}
        @built = {xpath: ".//*[local-name()='span']", visible_text: 'foo'}
      end

      it 'raises exception when visible is not boolean', skip_after: true do
        selector = {visible: 'foo'}
        msg = 'expected one of [TrueClass, FalseClass], got "foo":String'
        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end

      it 'raises exception when visible text is not a String or Regexp', skip_after: true do
        selector = {visible_text: 7}
        msg = /expected one of \[String, Regexp\], got 7:(Fixnum|Integer)/
        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end
    end
  end
end
