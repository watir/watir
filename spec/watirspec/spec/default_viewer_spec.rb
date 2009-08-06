require File.dirname(__FILE__) + '/spec_helper.rb'

describe "DefaultViewer" do

  before :all do
    @browser = Browser.new(BROWSER_OPTIONS)
    @browser.goto(WatirSpec.files + "/definition_lists.html")
  end

  describe ".save" do
    it "saves the default image to the given path" do
      fail("don't run specs with CelerityViewer") if @browser.viewer != Celerity::DefaultViewer
      fname   = File.expand_path "default_viewer_test.png"
      default = "#{File.dirname(__FILE__)}/../lib/celerity/resources/no_viewer.png"

      @browser.viewer.save(fname)
      File.exist?(fname).should be_true
      File.read(fname).should == File.read(default)

      File.delete(fname)
    end
  end
end

