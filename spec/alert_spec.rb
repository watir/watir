require File.expand_path("watirspec/spec_helper", File.dirname(__FILE__))
require "watir-webdriver/extensions/alerts"

describe "AlertHelper" do
  before do
    browser.goto("file://" + File.expand_path("html/alerts.html", File.dirname(__FILE__)))
  end

  it "handles an alert()" do
    returned = browser.alert do
      browser.button(:id => "alert").click
    end

    returned.should == "ok"
  end

  it "handles a confirmed confirm()" do
    returned = browser.confirm(true) do
      browser.button(:id => "confirm").click
    end

    returned.should == "set the value"

    browser.button(:id => "confirm").value.should == "true"
  end

  it "handles a cancelled confirm()" do
    returned = browser.confirm(false) do
      browser.button(:id => "confirm").click
    end

    returned.should == "set the value"

    browser.button(:id => "confirm").value.should == "false"
  end

  it "handles a prompt()" do
    returned = browser.prompt("my name") do
      browser.button(:id => "prompt").click
    end

    returned.should == {
      :message       => "enter your name",
      :default_value => "John Doe"
    }

    browser.button(:id => "prompt").value.should == "my name"
  end
end
