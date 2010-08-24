require File.expand_path("spec_helper", File.dirname(__FILE__))

describe Watir::ElementLocator do

  before { @driver = mock(Selenium::WebDriver::Driver) }

  #
  # helpers
  #

  def locator(selector, attrs = Watir::HTMLElement.attributes)
    Watir::ElementLocator.new(@driver, selector, attrs)
  end

  def expect_first(*args)
    @driver.should_receive(:find_element).with(*args)
  end

  def expect_all(*args)
    @driver.should_receive(:find_elements).with(*args)
  end

  def locate_first(*args)
    locator(*args).locate
  end

  def locate_all(*args)
    locator(*args).locate_all
  end

  def element(opts = {})
    mock(Watir::Element, opts)
  end

  #
  # specs
  #


  it "finds an element by tag name" do
    expect_first :tag_name, 'div'
    locate_first :tag_name => "div"
  end

  it "finds an element by tag name + attribute" do
    expect_first :xpath, ".//div[@class='foo']"

    locate_first :tag_name => "div",
                 :class    => "foo"
  end

  it "finds an element by tag name + multiple attributes" do
    expect_first :xpath, ".//div[@class='foo' and @title='bar']"

    locate_first :tag_name => "div",
                 :class    => "foo",
                 :title    => 'bar'
  end

  #
  # single selector without tag name, delegate to webdriver
  #

  it "delegates to webdriver's :class locator" do
    expect_first :class, "bar"
    locate_first :class => "bar"
  end

  it "delegates to webdriver's :xpath locator" do
    expect_first :xpath, "foo"
    locate_first :xpath => "foo"
  end

  it "delegates to webdriver's :css locator" do
    expect_first :css, "foo"
    locate_first :css => "foo"
  end

  it "delegates to webdriver's :id locator" do
    expect_first(:id, "foo").and_return(element)

    locate_first :id => "foo"
  end

  it "finds an element if tag_name is missing + multiple attributes" do
    expect_first :xpath, ".//*[@class='foo' and @title='bar']"
    locate_first :class => "foo", :title => "bar"
  end


  ## this should be simple to support - figure out why it's currently not.
  #
  # it "finds an element by multiple values for the same attribute" do
  #   expect_first :xpath, ".//input[(@type='submit' or @type='button')]"
  #
  #   valid_attributes = [:type]
  #   selector = { :tag_name => "input", :type => %w[submit button] }
  #
  #
  #   locate_first selector, valid_attributes
  # end

end
