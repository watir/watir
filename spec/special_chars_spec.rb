require File.expand_path('watirspec/spec_helper', File.dirname(__FILE__))

describe Watir::Browser do

  before do
    browser.goto("file://" + File.expand_path("../html/special_chars.html", __FILE__))
  end

  it "finds elements with single quotes" do
    browser.div(:text => "single 'quotes'").should exist
  end

end
