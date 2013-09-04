require File.expand_path('watirspec/spec_helper', File.dirname(__FILE__))

describe Watir::Input do

  before do
    browser.goto WatirSpec.url_for("html5_input_types.html", :needs_server => true)
  end

  describe "#type" do
    it "returns an email type" do
      browser.input(:name => "email").type.should == 'email'
    end
  end
end
