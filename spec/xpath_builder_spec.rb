require "#{File.dirname(__FILE__)}/spec_helper"

describe Watir::XPathBuilder do
  def build(selector)
    XPathBuilder.build_from(selector)
  end

  it "builds an xpath from a tag name and a single attribute" do
    build(
      :tag_name => "div",
      :id       => "foo"
    ).should == '//div[@id="foo"]'
  end

  it "builds an xpath from a tag name and multiple attributes" do
    build(
      :tag_name => "input",
      :type     => "radio",
      :value    => '1'
    ).should == '//input[@type="radio" and @value="1"]'
  end

  it "builds an xpath from a tag name, an attribute and an index" do
    build(
      :tag_name => "input",
      :type => "text",
      :index => 2
    ).should == '//input[@type="text"][2]'
  end

  it "builds an xpath from a single attribute" do
    build(
      :class => 'foo'
    ).should == '//*[@class="foo"]'
  end

end