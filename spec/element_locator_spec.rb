require File.expand_path("spec_helper", File.dirname(__FILE__))

describe Watir::ElementLocator do

  before { @driver = mock(Selenium::WebDriver::Driver) }

  #
  # helpers
  #

  def locator(selector, attrs = Watir::HTMLElement.attributes)
    Watir::ElementLocator.new(@driver, selector, attrs)
  end

  def expect_one(*args)
    @driver.should_receive(:find_element).with(*args)
  end

  def expect_all(*args)
    @driver.should_receive(:find_elements).with(*args)
  end

  def locate_one(*args)
    locator(*args).locate
  end

  def locate_all(*args)
    locator(*args).locate_all
  end

  def element(opts = {})
    mock(Watir::Element, opts)
  end

  describe "finds a single element" do
    describe "by delegating to webdriver" do
      it "delegates to webdriver's :class locator" do
        expect_one :class, "bar"
        locate_one :class => "bar"
      end

      it "delegates to webdriver's :class_name locator" do
        expect_one :class_name, "bar"
        locate_one :class_name => "bar"
      end

      it "delegates to webdriver's :css locator" do
        expect_one :css, ".foo"
        locate_one :css => ".foo"
      end

      it "delegates to webdriver's :id locator" do
        expect_one(:id, "foo").and_return(element)
        locate_one :id => "foo"
      end

      it "delegates to webdriver's :name locator" do
        expect_one :name, "foo"
        locate_one :name => "foo"
      end

      it "delegates to webdriver's :tag_name locator" do
        expect_one :tag_name, "div"
        locate_one :tag_name => "div"
      end

      it "delegates to webdriver's :xpath locator" do
        expect_one :xpath, "//foo"
        locate_one :xpath => "//foo"
      end
    end

    #
    # selectors not supported by webdriver
    #
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

      it "handles selector with tag name and multiple attributes" do
        expect_one :xpath, ".//div[@class='foo' and @title='bar']"

        locate_one :tag_name => "div",
                     :class    => "foo",
                     :title    => 'bar'
      end

      it "handles selector with no tag name and multiple attributes" do
        expect_one :xpath, ".//*[@class='foo' and @title='bar']"

        locate_one :class => "foo",
                     :title => "bar"
      end
    end


    describe "with special cased selectors" do
      it "uses normalize-space() for :text" do
        expect_one :xpath, ".//div[normalize-space()='foo']"
        locate_one :tag_name => "div",
                     :text     => "foo"
      end

      it "translates :caption to :text" do
        expect_one :xpath, ".//div[normalize-space()='foo']"

        locate_one :tag_name => "div",
                     :caption => "foo"
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

        selector = {
          :tag_name => "input",
          :type     => "text",
          :label    => "foo"
        }

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

    it "finds all if :index is given" do
      # or could we use XPath indeces reliably instead?
      arr = [
        element(:tag_name => "div"),
        element(:tag_name => "div")
      ]

      expect_all(:xpath, ".//div[@class='foo']").and_return(arr)

      selector = {
        :tag_name => "div",
        :class    => "foo",
        :index    => 1
      }

      locate_one(selector).should == arr[1]
    end

    # TODO: locate_one for regexp selectors.
    # TODO: locate_all


    #
    # errors
    #

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
