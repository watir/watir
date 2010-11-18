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
        expect_one :xpath, ".//div[@class='foo']"

        locate_one :tag_name => "div",
                   :class    => "foo"
      end

      it "handles selector with no tag name and and a single attribute" do
        expect_one :xpath, ".//*[@title='foo']"
        locate_one :title => "foo"
      end

      it "handles single quotes in the attribute string" do
        expect_one :xpath, %{.//*[@title=concat('foo and ',"'",'bar',"'",'')]}
        locate_one :title => "foo and 'bar'"
      end

      it "handles selector with tag name and multiple attributes" do
        expect_one :xpath, ".//div[@class='foo' and @title='bar']"

        locate_one [:tag_name, "div",
                    :class   , "foo",
                    :title   , 'bar']
      end

      it "handles selector with no tag name and multiple attributes" do
        expect_one :xpath, ".//*[@class='foo' and @title='bar']"

        locate_one [:class, "foo",
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
        expect_one :xpath, ".//div[@class='foo']"

        locate_one :tag_name   => "div",
                   :class_name => "foo"
      end

      it "handles data-* attributes" do
        expect_one :xpath, ".//div[@data-name='foo']"

        locate_one :tag_name  => "div",
                   :data_name => "foo"
      end

      it "normalizes space for the :href attribute" do
        expect_one :xpath, ".//a[normalize-space(@href)='foo']"

        selector = {
          :tag_name => "a",
          :href     => "foo"
        }

        locate_one selector, Watir::Anchor.attributes
      end

      it "uses the corresponding <label>'s @for attribute when locating by label" do
        expect_one :xpath, ".//input[@type='text' and @id=//label[normalize-space()='foo']/@for]"

        selector = [
          :tag_name, "input",
          :type    , "text",
          :label   , "foo"
        ]

        locate_one selector, Watir::Input.attributes
      end

      it "does not use the label element for <option> elements" do
        expect_one :xpath, ".//option[@label='foo']"

        locate_one :tag_name => "option",
                   :label    => "foo"
      end

      it "translates ruby attribute names to content attribute names" do
        expect_one :xpath, ".//meta[@http-equiv='foo']"

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

        expect_all(:xpath, ".//div").and_return(elements)
        locate_one(:tag_name => "div", :class => /oob/).should == elements[1]
      end

      it "handles :tag_name, :index and a single regexp attribute" do
        elements = [
          element(:tag_name => "div", :attributes => { :class => "foo" }),
          element(:tag_name => "div", :attributes => { :class => "foo" })
        ]

        expect_all(:xpath, ".//div").and_return(elements)

        selector = {
          :tag_name => "div",
          :class    => /foo/,
          :index    => 1
        }

        locate_one(selector).should == elements[1]
      end

      it "handles mix of string and regexp attributes" do
        elements = [
          element(:tag_name => "div", :attributes => { :class => "foo", :title => "bar" }),
          element(:tag_name => "div", :attributes => { :class => "foo", :title => "baz" })
        ]

        expect_all(:xpath, ".//div[@class='foo']").and_return(elements)

        selector = {
          :tag_name => "div",
          :class    => "foo",
          :title    => /baz/
        }

        locate_one(selector).should == elements[1]
      end

      it "handles :label => /regexp/ selector" do
        label_elements = [
          element(:tag_name => "label", :text => "foo", :attributes => { :for => "bar"}),
          element(:tag_name => "label", :text => "foob", :attributes => { :for => "baz"})
        ]
        div_elements = [element(:tag_name => "div")]

        expect_all(:tag_name, "label").ordered.and_return(label_elements)
        expect_all(:xpath, ".//div[@id='baz']").ordered.and_return(div_elements)

        locate_one(:tag_name => "div", :label => /oob/).should == div_elements.first
      end

      it "returns nil when no label matching the regexp is found" do
        expect_all(:tag_name, "label").and_return([])
        locate_one(:tag_name => "div", :label => /foo/).should be_nil
      end

    end

    it "finds all if :index is given" do
      # or could we use XPath indeces reliably instead?
      elements = [
        element(:tag_name => "div"),
        element(:tag_name => "div")
      ]

      expect_all(:xpath, ".//div[@class='foo']").and_return(elements)

      selector = {
        :tag_name => "div",
        :class    => "foo",
        :index    => 1
      }

      locate_one(selector).should == elements[1]
    end

    it "returns nil if found element didn't match the selector tag_name" do
      expect_one(:xpath, "//div").and_return(element(:tag_name => "div"))

      selector = {
        :tag_name => "input",
        :xpath    => "//div"
      }

      locate_one(selector, Watir::Input.attributes).should be_nil
    end

    describe "errors" do
      it "raises a TypeError if :index is not a Fixnum" do
        lambda {
          locate_one(:tag_name => "div", :index => "bar")
        }.should raise_error(TypeError, %[expected Fixnum, got "bar":String])
      end

      it "raises a TypeError if selector value is not a String or Regexp" do
        lambda {
          locate_one(:tag_name => 123)
        }.should raise_error(TypeError, %[expected one of [String, Regexp], got 123:Fixnum])
      end

      it "raises a MissingWayOfFindingObjectException if the attribute is not valid" do
        bad_selector = {:tag_name => "input", :href => "foo"}
        valid_attributes = Watir::Input.attributes

        lambda {
          locate_one(bad_selector, valid_attributes)
        }.should raise_error(MissingWayOfFindingObjectException, "invalid attribute: :href")
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

    describe "with selectors not supported by webdriver" do
      it "handles selector with tag name and a single attribute" do
        expect_all :xpath, ".//div[@class='foo']"

        locate_all :tag_name => "div",
                   :class    => "foo"
      end

      it "handles selector with tag name and multiple attributes" do
        expect_all :xpath, ".//div[@class='foo' and @title='bar']"

        locate_all [:tag_name, "div",
                    :class   , "foo",
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

        expect_all(:xpath, ".//div").and_return(elements)
        locate_all(:tag_name => "div", :class => /oob/).should == elements.last(3)
      end

      it "handles mix of string and regexp attributes" do
        elements = [
          element(:tag_name => "div", :attributes => { :class => "foo", :title => "bar" }),
          element(:tag_name => "div", :attributes => { :class => "foo", :title => "baz" }),
          element(:tag_name => "div", :attributes => { :class => "foo", :title => "bazt"})
        ]

        expect_all(:xpath, ".//div[@class='foo']").and_return(elements)

        selector = {
          :tag_name => "div",
          :class    => "foo",
          :title    => /baz/
        }

        locate_all(selector).should == elements.last(2)
      end
    end

    describe "errors" do
      it "raises ArgumentError if :index is given" do
        lambda {
          locate_all(:tag_name => "div", :index => 1)
        }.should raise_error(ArgumentError, "can't locate all elements by :index")
      end
    end
  end

end
