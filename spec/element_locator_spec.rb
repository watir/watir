require File.expand_path("spec_helper", File.dirname(__FILE__))

describe Watir::ElementLocator do
  include LocatorSpecHelper

  describe "finds a single element" do
    describe "by delegating to webdriver" do
      WEBDRIVER_SELECTORS.each do |loc|
        it "delegates to webdriver's #{loc} locator" do
          expect_one(loc, "bar").and_return(element(:tag_name => "div"))
          locate_one loc => "bar"
        end
      end
    end

    describe "with selectors not supported by webdriver" do
      it "handles selector with tag name and a single attribute" do
        if Watir.prefer_css?
          expect_one :css, 'div[title="foo"]'
        else
          expect_one :xpath, ".//div[@title='foo']"
        end

        locate_one :tag_name => "div",
                   :title    => "foo"
      end

      it "handles selector with no tag name and and a single attribute" do
        if Watir.prefer_css?
          expect_one :css, '[title="foo"]'
        else
          expect_one :xpath, ".//*[@title='foo']"
        end

        locate_one :title => "foo"
      end

      it "handles single quotes in the attribute string" do
        if Watir.prefer_css?
          expect_one :css, %{[title="foo and 'bar'"]}
        else
          expect_one :xpath, %{.//*[@title=concat('foo and ',"'",'bar',"'",'')]}
        end

        locate_one :title => "foo and 'bar'"
      end

      it "handles selector with tag name and multiple attributes" do
        if Watir.prefer_css?
          expect_one :css, 'div[title="foo"][dir="bar"]'
        else
          expect_one :xpath, ".//div[@title='foo' and @dir='bar']"
        end

        locate_one [:tag_name, "div",
                    :title   , "foo",
                    :dir     , 'bar']
      end

      it "handles selector with no tag name and multiple attributes" do
        if Watir.prefer_css?
          expect_one :css, '[dir="foo"][title="bar"]'
        else
          expect_one :xpath, ".//*[@dir='foo' and @title='bar']"
        end

        locate_one [:dir,   "foo",
                    :title, "bar"]
      end
    end


    describe "with special cased selectors" do
      it "normalizes space for :text" do
        expect_one :xpath, ".//div[normalize-space()='foo']"
        locate_one :tag_name => "div",
                   :text     => "foo"
      end

      it "translates :caption to :text" do
        expect_one :xpath, ".//div[normalize-space()='foo']"

        locate_one :tag_name => "div",
                   :caption  => "foo"
      end

      it "translates :class_name to :class" do
        if Watir.prefer_css?
          expect_one :css, "div.foo"
        else
          expect_one :xpath, ".//div[contains(concat(' ', @class, ' '), ' foo ')]"
        end

        locate_one :tag_name   => "div",
                   :class_name => "foo"
      end

      it "handles data-* attributes" do
        if Watir.prefer_css?
          expect_one :css, 'div[data-name="foo"]'
        else
          expect_one :xpath, ".//div[@data-name='foo']"
        end

        locate_one :tag_name  => "div",
                   :data_name => "foo"
      end

      it "handles aria-* attributes" do
        if Watir.prefer_css?
          expect_one :css, 'div[aria-label="foo"]'
        else
          expect_one :xpath, ".//div[@aria-label='foo']"
        end

        locate_one :tag_name  => "div",
                   :aria_label => "foo"
      end

      it "normalizes space for the :href attribute" do
        if Watir.prefer_css?
          expect_one :css, 'a[href~="foo"]'
        else
          expect_one :xpath, ".//a[normalize-space(@href)='foo']"
        end

        selector = {
          :tag_name => "a",
          :href     => "foo"
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

        selector = { :tag_name => "option", :label => "foo" }
        locate_one selector, Watir::Option.attributes
      end

      it "translates ruby attribute names to content attribute names" do
        if Watir.prefer_css?
          expect_one :css, 'meta[http-equiv="foo"]'
        else
          expect_one :xpath, ".//meta[@http-equiv='foo']"
        end

        selector = {
          :tag_name   => "meta",
          :http_equiv => "foo"
        }

        locate_one selector, Watir::Meta.attributes

        # TODO: check edge cases
      end
    end

    describe "with regexp selectors" do
      it "handles selector with tag name and a single regexp attribute" do
        elements = [
          element(:tag_name => "div", :attributes => { :class => "foo" }),
          element(:tag_name => "div", :attributes => { :class => "foob"})
        ]

        if Watir.prefer_css?
          expect_all(:css, "div").and_return(elements)
        else
          expect_all(:xpath, ".//div").and_return(elements)
        end

        expect(locate_one(:tag_name => "div", :class => /oob/)).to eq elements[1]
      end

      it "handles :tag_name, :index and a single regexp attribute" do
        elements = [
          element(:tag_name => "div", :attributes => { :class => "foo" }),
          element(:tag_name => "div", :attributes => { :class => "foo" })
        ]

        if Watir.prefer_css?
          expect_all(:css, "div").and_return(elements)
        else
          expect_all(:xpath, ".//div").and_return(elements)
        end

        selector = {
          :tag_name => "div",
          :class    => /foo/,
          :index    => 1
        }

        expect(locate_one(selector)).to eq elements[1]
      end

      it "handles :xpath and :index selectors" do
        elements = [
          element(:tag_name => "div", :attributes => { :class => "foo" }),
          element(:tag_name => "div", :attributes => { :class => "foo" })
        ]

        expect_all(:xpath, './/div[@class="foo"]').and_return(elements)

        selector = {
          :xpath => './/div[@class="foo"]',
          :index => 1
        }

        expect(locate_one(selector)).to eq elements[1]
      end

      it "handles :css and :index selectors" do
        elements = [
          element(:tag_name => "div", :attributes => { :class => "foo" }),
          element(:tag_name => "div", :attributes => { :class => "foo" })
        ]

        expect_all(:css, 'div[class="foo"]').and_return(elements)

        selector = {
          :css   => 'div[class="foo"]',
          :index => 1
        }

        expect(locate_one(selector)).to eq elements[1]
      end

      it "handles mix of string and regexp attributes" do
        elements = [
          element(:tag_name => "div", :attributes => { :dir => "foo", :title => "bar" }),
          element(:tag_name => "div", :attributes => { :dir => "foo", :title => "baz" })
        ]

        if Watir.prefer_css?
          expect_all(:css, 'div[dir="foo"]').and_return(elements)
        else
          expect_all(:xpath, ".//div[@dir='foo']").and_return(elements)
        end


        selector = {
          :tag_name => "div",
          :dir      => "foo",
          :title    => /baz/
        }

        expect(locate_one(selector)).to eq elements[1]
      end

      it "handles data-* attributes with regexp" do
        elements = [
          element(:tag_name => "div", :attributes => { :'data-automation-id' => "foo" }),
          element(:tag_name => "div", :attributes => { :'data-automation-id' => "bar" })
        ]

        if Watir.prefer_css?
          expect_all(:css, 'div').and_return(elements)
        else
          expect_all(:xpath, ".//div").and_return(elements)
        end


        selector = {
          :tag_name => "div",
          :data_automation_id => /bar/
        }

        expect(locate_one(selector)).to eq elements[1]
      end

      it "handles :label => /regexp/ selector" do
        label_elements = [
          element(:tag_name => "label", :text => "foo", :attributes => { :for => "bar"}),
          element(:tag_name => "label", :text => "foob", :attributes => { :for => "baz"})
        ]
        div_elements = [element(:tag_name => "div")]

        expect_all(:tag_name, "label").ordered.and_return(label_elements)

        if Watir.prefer_css?
          expect_all(:css, 'div[id="baz"]').ordered.and_return(div_elements)
        else
          expect_all(:xpath, ".//div[@id='baz']").ordered.and_return(div_elements)
        end

        expect(locate_one(:tag_name => "div", :label => /oob/)).to eq div_elements.first
      end

      it "returns nil when no label matching the regexp is found" do
        expect_all(:tag_name, "label").and_return([])
        expect(locate_one(:tag_name => "div", :label => /foo/)).to be_nil
      end

    end

    it "finds all if :index is given" do
      # or could we use XPath indeces reliably instead?
      elements = [
        element(:tag_name => "div"),
        element(:tag_name => "div")
      ]

      if Watir.prefer_css?
        expect_all(:css, 'div[dir="foo"]').and_return(elements)
      else
        expect_all(:xpath, ".//div[@dir='foo']").and_return(elements)
      end

      selector = {
        :tag_name => "div",
        :dir      => "foo",
        :index    => 1
      }

      expect(locate_one(selector)).to eq elements[1]
    end

    it "returns nil if found element didn't match the selector tag_name" do
      expect_one(:xpath, "//div").and_return(element(:tag_name => "div"))

      selector = {
        :tag_name => "input",
        :xpath    => "//div"
      }

      expect(locate_one(selector, Watir::Input.attributes)).to be_nil
    end

    describe "errors" do
      it "raises a TypeError if :index is not a Fixnum" do
        expect { locate_one(:tag_name => "div", :index => "bar") }.to \
        raise_error(TypeError, %[expected Fixnum, got "bar":String])
      end

      it "raises a TypeError if selector value is not a String or Regexp" do
        expect { locate_one(:tag_name => 123) }.to \
        raise_error(TypeError, %[expected one of [String, Regexp], got 123:Fixnum])
      end

      it "raises a MissingWayOfFindingObjectException if the attribute is not valid" do
        bad_selector = {:tag_name => "input", :href => "foo"}
        valid_attributes = Watir::Input.attributes

        expect { locate_one(bad_selector, valid_attributes) }.to \
        raise_error(Watir::Exception::MissingWayOfFindingObjectException, "invalid attribute: :href")
      end
    end
  end

  describe "finds several elements" do
    describe "by delegating to webdriver" do
      WEBDRIVER_SELECTORS.each do |loc|
        it "delegates to webdriver's #{loc} locator" do
          expect_all(loc, "bar").and_return([element(:tag_name => "div")])
          locate_all(loc => "bar")
        end
      end
    end

    describe "with an empty selector" do
      it "finds all when an empty selctor is given" do
        if Watir.prefer_css?
          expect_all :css, '*'
        else
          expect_all :xpath, './/*'
        end

        locate_all({})
      end
    end

    describe "with selectors not supported by webdriver" do
      it "handles selector with tag name and a single attribute" do
        if Watir.prefer_css?
          expect_all :css, 'div[dir="foo"]'
        else
          expect_all :xpath, ".//div[@dir='foo']"
        end

        locate_all :tag_name => "div",
                   :dir      => "foo"
      end

      it "handles selector with tag name and multiple attributes" do
        if Watir.prefer_css?
          expect_all :css, 'div[dir="foo"][title="bar"]'
        else
          expect_all :xpath, ".//div[@dir='foo' and @title='bar']"
        end

        locate_all [:tag_name, "div",
                    :dir     , "foo",
                    :title   , 'bar']
      end
    end

    describe "with regexp selectors" do
      it "handles selector with tag name and a single regexp attribute" do
        elements = [
          element(:tag_name => "div", :attributes => { :class => "foo" }),
          element(:tag_name => "div", :attributes => { :class => "foob"}),
          element(:tag_name => "div", :attributes => { :class => "doob"}),
          element(:tag_name => "div", :attributes => { :class => "noob"})
        ]

        if Watir.prefer_css?
          expect_all(:css, "div").and_return(elements)
        else
          expect_all(:xpath, ".//div").and_return(elements)
        end

        expect(locate_all(:tag_name => "div", :class => /oob/)).to eq elements.last(3)
      end

      it "handles mix of string and regexp attributes" do
        elements = [
          element(:tag_name => "div", :attributes => { :dir => "foo", :title => "bar" }),
          element(:tag_name => "div", :attributes => { :dir => "foo", :title => "baz" }),
          element(:tag_name => "div", :attributes => { :dir => "foo", :title => "bazt"})
        ]

        if Watir.prefer_css?
          expect_all(:css, 'div[dir="foo"]').and_return(elements)
        else
          expect_all(:xpath, ".//div[@dir='foo']").and_return(elements)
        end

        selector = {
          :tag_name => "div",
          :dir      => "foo",
          :title    => /baz/
        }

        expect(locate_all(selector)).to eq elements.last(2)
      end
    end

    describe "errors" do
      it "raises ArgumentError if :index is given" do
        expect { locate_all(:tag_name => "div", :index => 1) }.to \
        raise_error(ArgumentError, "can't locate all elements by :index")
      end
    end
  end

end
