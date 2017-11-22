require 'spec_helper'

describe Watir::Locators::Element::Locator do
  include LocatorSpecHelper

  describe "finds a single element" do
    describe "by delegating to Selenium" do
      SELENIUM_SELECTORS.each do |loc|
        it "delegates to Selenium's #{loc} locator" do
          expect_one(loc, "bar").and_return(element(tag_name: "div"))
          match = %i[link link_text partial_link_text].include?(loc) ? :to : :to_not
          msg = /:#{loc} locator is deprecated\. Use :visible_text instead/
          expect { locate_one loc => "bar" }.send(match, output(msg).to_stdout_from_any_process)
        end
      end
    end

    describe "with selectors not supported by Selenium" do
      it "handles selector with tag name and a single attribute" do
        expect_one :xpath, ".//div[@title='foo']"

        locate_one tag_name: "div",
                   title: "foo"
      end

      it "handles selector with no tag name and and a single attribute" do
        expect_one :xpath, ".//*[@title='foo']"

        locate_one title: "foo"
      end

      it "handles single quotes in the attribute string" do
        expect_one :xpath, %{.//*[@title=concat('foo and ',"'",'bar',"'",'')]}

        locate_one title: "foo and 'bar'"
      end

      it "handles selector with tag name and multiple attributes" do
        expect_one :xpath, ".//div[@title='foo' and @dir='bar']"

        locate_one [:tag_name, "div",
                    :title   , "foo",
                    :dir     , 'bar']
      end

      it "handles selector with no tag name and multiple attributes" do
        expect_one :xpath, ".//*[@dir='foo' and @title='bar']"

        locate_one [:dir,   "foo",
                    :title, "bar"]
      end

      it "handles selector with attribute presence" do
        expect_one :xpath, ".//*[@data-view]"

        locate_one [:data_view, true]
      end

      it "handles selector with attribute absence" do
        expect_one :xpath, ".//*[not(@data-view)]"

        locate_one [:data_view, false]
      end

      it "handles selector with class attribute presence" do
        expect_one :xpath, ".//*[@class]"

        locate_one class: true
      end

      it "handles selector with multiple classes in array" do
        expect_one :xpath, ".//*[(contains(concat(' ', @class, ' '), ' a ') and contains(concat(' ', @class, ' '), ' b '))]"

        locate_one class: ["a", "b"]
      end

      it "handles selector with multiple classes in string" do
        expect_one :xpath, ".//*[contains(concat(' ', @class, ' '), ' a b ')]"

        msg = /:class locator to locate multiple classes with a String value is deprecated\. Use Array instead/
        expect { locate_one class: "a b" }.to output(msg).to_stdout_from_any_process
      end

      it "handles selector with tag_name and xpath" do
          elements = [
              element(tag_name: "div", attributes: { class: "foo" }),
              element(tag_name: "span", attributes: { class: "foo" }),
              element(tag_name: "div", attributes: { class: "foo" })
          ]

          expect_one(:xpath, './/*[@class="foo"]').and_return(elements.first)
          expect_all(:xpath, './/*[@class="foo"]').and_return(elements)

          selector = {
              xpath: './/*[@class="foo"]',
              tag_name: 'span'
          }

          expect(locate_one(selector).tag_name).to eq 'span'
      end

      it "handles custom attributes" do
        elements = [
            element(tag_name: "div", attributes: { custom_attribute: "foo" }),
            element(tag_name: "span", attributes: { custom_attribute: "foo" }),
            element(tag_name: "div", attributes: { custom_attribute: "foo" })
        ]

        expect_one(:xpath, ".//span[@custom-attribute='foo']").and_return(elements[1])

        selector = {
            custom_attribute: 'foo',
            tag_name: 'span'
        }

        expect(locate_one(selector).tag_name).to eq 'span'
      end
    end

    describe "with special cased selectors" do
      it "normalizes space for :text" do
        expect_one :xpath, ".//div[normalize-space()='foo']"
        locate_one tag_name: "div",
                   text: "foo"
      end

      it "translates :caption to :text" do
        expect_one :xpath, ".//div[normalize-space()='foo']"

        locate_one tag_name: "div",
                   caption: "foo"
      end

      it "handles data-* attributes" do
        expect_one :xpath, ".//div[@data-name='foo']"

        locate_one tag_name: "div",
                   data_name: "foo"
      end

      it "handles aria-* attributes" do
        expect_one :xpath, ".//div[@aria-label='foo']"

        locate_one tag_name: "div",
                   aria_label: "foo"
      end

      it "normalizes space for the :href attribute" do
        expect_one :xpath, ".//a[normalize-space(@href)='foo']"

        selector = {
          tag_name: "a",
          href: "foo"
        }

        locate_one selector, Watir::Anchor.attributes
      end

      it "wraps :type attribute with translate() for upper case values" do
        translated_type = "translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
        expect_one :xpath, ".//input[#{translated_type}='file']"

        selector = [
          :tag_name, "input",
          :type    , "file",
        ]

        locate_one selector, Watir::Input.attributes
      end

      it "uses the corresponding <label>'s @for attribute or parent::label when locating by label" do
        translated_type = "translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
        expect_one :xpath, ".//input[#{translated_type}='text' and (@id=//label[normalize-space()='foo']/@for or parent::label[normalize-space()='foo'])]"

        selector = [
          :tag_name, "input",
          :type    , "text",
          :label   , "foo"
        ]

        locate_one selector, Watir::Input.attributes
      end

      it "uses label attribute if it is valid for element" do
        expect_one :xpath, ".//option[@label='foo']"

        selector = { tag_name: "option", label: "foo" }
        locate_one selector, Watir::Option.attributes
      end

      it "translates ruby attribute names to content attribute names" do
        expect_one :xpath, ".//meta[@http-equiv='foo']"

        selector = {
          tag_name: "meta",
          http_equiv: "foo"
        }

        locate_one selector, Watir::Meta.attributes

        # TODO: check edge cases
      end
    end

    describe "with regexp selectors" do
      it "handles selector with tag name and a single regexp attribute" do
        elements = [
          element(tag_name: "div", attributes: { class: "foo" }),
          element(tag_name: "div", attributes: { class: "foob"})
        ]

        expect_all(:xpath, "(.//div)[contains(@class, 'oob')]").and_return(elements)

        expect(locate_one(tag_name: "div", class: /oob/)).to eq elements[1]
      end

      it "handles :tag_name, :index and a single regexp attribute" do
        elements = [
          element(tag_name: "div", attributes: { class: "foo" }),
          element(tag_name: "div", attributes: { class: "foo" })
        ]

        expect_all(:xpath, "(.//div)[contains(@class, 'foo')]").and_return(elements)

        selector = {
          tag_name: "div",
          class: /foo/,
          index: 1
        }

        expect(locate_one(selector)).to eq elements[1]
      end

      it "handles :xpath and :index selectors" do
        elements = [
          element(tag_name: "div", attributes: { class: "foo" }),
          element(tag_name: "div", attributes: { class: "foo" })
        ]

        expect_all(:xpath, './/div[@class="foo"]').and_return(elements)

        selector = {
          xpath: './/div[@class="foo"]',
          index: 1
        }

        expect(locate_one(selector)).to eq elements[1]
      end

      it "handles :css and :index selectors" do
        elements = [
          element(tag_name: "div", attributes: { class: "foo" }),
          element(tag_name: "div", attributes: { class: "foo" })
        ]

        expect_all(:css, 'div[class="foo"]').and_return(elements)

        selector = {
          css: 'div[class="foo"]',
          index: 1
        }

        expect(locate_one(selector)).to eq elements[1]
      end

      it "handles mix of string and regexp attributes" do
        elements = [
          element(tag_name: "div", attributes: { dir: "foo", title: "bar" }),
          element(tag_name: "div", attributes: { dir: "foo", title: "baz" })
        ]

        expect_all(:xpath, "(.//div[@dir='foo'])[contains(@title, 'baz')]").and_return(elements)

        selector = {
          tag_name: "div",
          dir: "foo",
          title: /baz/
        }

        expect(locate_one(selector)).to eq elements[1]
      end

      it "handles data-* attributes with regexp" do
        elements = [
          element(tag_name: "div", attributes: { :'data-automation-id' => "foo" }),
          element(tag_name: "div", attributes: { :'data-automation-id' => "bar" })
        ]

        expect_all(:xpath, "(.//div)[contains(@data-automation-id, 'bar')]").and_return(elements)

        selector = {
          tag_name: "div",
          data_automation_id: /bar/
        }

        expect(locate_one(selector)).to eq elements[1]
      end

      it "handles :label => /regexp/ selector" do
        label_elements = [
          element(tag_name: "label", text: "foo", attributes: { 'for' => "bar"}),
          element(tag_name: "label", text: "foob", attributes: { 'for' => "baz"})
        ]
        div_elements = [element(tag_name: "div")]

        expect_all(:tag_name, "label").ordered.and_return(label_elements)
        expect_all(:xpath, ".//div[@id='baz']").ordered.and_return(div_elements)

        allow(browser).to receive(:ensure_context).and_return(nil)
        allow(browser).to receive(:execute_script).and_return('foo', 'foob')

        expect(locate_one(tag_name: "div", label: /oob/)).to eq div_elements.first
      end

      it "returns nil when no label matching the regexp is found" do
        expect_all(:tag_name, "label").and_return([])
        expect(locate_one(tag_name: "div", label: /foo/)).to be_nil
      end
    end

    it "finds all if :index is given" do
      # or could we use XPath indeces reliably instead?
      elements = [
        element(tag_name: "div"),
        element(tag_name: "div")
      ]

      expect_all(:xpath, ".//div[@dir='foo']").and_return(elements)

      selector = {
        tag_name: "div",
        dir: "foo",
        index: 1
      }

      expect(locate_one(selector)).to eq elements[1]
    end

    it "returns nil if found element didn't match the selector tag_name" do
      expect_one(:xpath, "//div").and_return(element(tag_name: "div"))
      expect_all(:xpath, "//div").and_return([element(tag_name: "div")])

      selector = {
        tag_name: "input",
        xpath: "//div"
      }

      expect(locate_one(selector, Watir::Input.attributes)).to be_nil
    end

    describe "errors" do
      it "raises a TypeError if :index is not a Integer" do
        expect { locate_one(tag_name: "div", index: "bar") }.to \
        raise_error(TypeError, %[expected Integer, got "bar":String])
      end

      it "raises a TypeError if selector value is not a String, Regexp or Boolean" do
        num_type = RUBY_VERSION[/^\d+\.(\d+)/, 1].to_i >= 4 ? 'Integer' : 'Fixnum'
        expect { locate_one(tag_name: 123) }.to \
        raise_error(TypeError, %[expected one of [Array, String, Regexp, TrueClass, FalseClass, Symbol], got 123:#{num_type}])
      end
    end
  end

  describe "finds several elements" do
    describe "by delegating to Selenium" do
      SELENIUM_SELECTORS.each do |loc|
        it "delegates to Selenium's #{loc} locator" do
          expect_all(loc, "bar").and_return([element(tag_name: "div")])
          match = %i[link link_text partial_link_text].include?(loc) ? :to : :to_not
          msg = /:#{loc} locator is deprecated\. Use :visible_text instead/
          expect { locate_all loc => "bar" }.send(match, output(msg).to_stdout_from_any_process)
        end
      end
    end

    describe "with an empty selector" do
      it "finds all when an empty selctor is given" do
        expect_all :xpath, './/*'
        locate_all({})
      end
    end

    describe "with selectors not supported by Selenium" do
      it "handles selector with tag name and a single attribute" do
        expect_all :xpath, ".//div[@dir='foo']"
        locate_all tag_name: "div",
                   dir: "foo"
      end

      it "handles selector with tag name and multiple attributes" do
        expect_all :xpath, ".//div[@dir='foo' and @title='bar']"
        locate_all [:tag_name, "div",
                    :dir     , "foo",
                    :title   , 'bar']
      end

      it "handles selector with class attribute presence" do
        expect_all :xpath, ".//*[@class]"

        locate_all class: true
      end

      it "handles selector with multiple classes in array" do
        expect_all :xpath, ".//*[(contains(concat(' ', @class, ' '), ' a ') and contains(concat(' ', @class, ' '), ' b '))]"

        locate_all class: ["a", "b"]
      end

      it "handles selector with multiple classes in string" do
        expect_all :xpath, ".//*[contains(concat(' ', @class, ' '), ' a b ')]"

        msg = /Using the :class locator to locate multiple classes with a String value is deprecated\. Use Array instead/
        expect { locate_all class: "a b" }.to output(msg).to_stdout_from_any_process
      end
    end

    describe "with regexp selectors" do
      it "handles selector with tag name and a single regexp attribute" do
        elements = [
          element(tag_name: "div", attributes: { class: "foo" }),
          element(tag_name: "div", attributes: { class: "foob"}),
          element(tag_name: "div", attributes: { class: "doob"}),
          element(tag_name: "div", attributes: { class: "noob"})
        ]

        expect_all(:xpath, "(.//div)[contains(@class, 'oob')]").and_return(elements)
        expect(locate_all(tag_name: "div", class: /oob/)).to eq elements.last(3)
      end

      it "handles mix of string and regexp attributes" do
        elements = [
          element(tag_name: "div", attributes: { dir: "foo", title: "bar" }),
          element(tag_name: "div", attributes: { dir: "foo", title: "baz" }),
          element(tag_name: "div", attributes: { dir: "foo", title: "bazt"})
        ]

        expect_all(:xpath, "(.//div[@dir='foo'])[contains(@title, 'baz')]").and_return(elements)

        selector = {
          tag_name: "div",
          dir: "foo",
          title: /baz/
        }

        expect(locate_all(selector)).to eq elements.last(2)
      end

      context "and xpath" do
        it "converts a leading run of regexp literals to a contains() expression" do
          elements = [
            element(tag_name: "div", attributes: { class: "foo" }),
            element(tag_name: "div", attributes: { class: "foob" }),
            element(tag_name: "div", attributes: { class: "bar" })
          ]

          expect_all(:xpath, "(.//div)[contains(@class, 'fo')]").and_return(elements.first(2))

          expect(locate_one(tag_name: "div", class: /fo.b$/)).to eq elements[1]
        end

        it "converts a trailing run of regexp literals to a contains() expression" do
          elements = [
            element(tag_name: "div", attributes: { class: "foo" }),
            element(tag_name: "div", attributes: { class: "foob" })
          ]

          expect_all(:xpath, "(.//div)[contains(@class, 'b')]").and_return(elements.last(1))

          expect(locate_one(tag_name: "div", class: /^fo.b/)).to eq elements[1]
        end

        it "converts a leading and a trailing run of regexp literals to a contains() expression" do
          elements = [
            element(tag_name: "div", attributes: { class: "foo" }),
            element(tag_name: "div", attributes: { class: "foob" })
          ]

          expect_all(:xpath, "(.//div)[contains(@class, 'fo') and contains(@class, 'b')]").
            and_return(elements.last(1))

          expect(locate_one(tag_name: "div", class: /fo.b/)).to eq elements[1]
        end

        it "does not try to convert case insensitive expressions" do
          elements = [
            element(tag_name: "div", attributes: { class: "foo" }),
            element(tag_name: "div", attributes: { class: "foob"})
          ]

          expect_all(:xpath, ".//div").and_return(elements.last(1))

          expect(locate_one(tag_name: "div", class: /FOOB/i)).to eq elements[1]
        end

        it "does not try to convert expressions containing '|'" do
          elements = [
            element(tag_name: "div", attributes: { class: "foo" }),
            element(tag_name: "div", attributes: { class: "foob"})
          ]

          expect_all(:xpath, ".//div").and_return(elements.last(1))

          expect(locate_one(tag_name: "div", class: /x|b/)).to eq elements[1]
        end
      end
    end

    describe "errors" do
      it "raises ArgumentError if :index is given" do
        expect { locate_all(tag_name: "div", index: 1) }.to \
        raise_error(ArgumentError, "can't locate all elements by :index")
      end
    end
  end

end
