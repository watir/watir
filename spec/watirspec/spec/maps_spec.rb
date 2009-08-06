require File.dirname(__FILE__) + '/spec_helper.rb'

describe "Maps" do

  before :all do
    @browser = Browser.new(BROWSER_OPTIONS)
  end

  before :each do
    @browser.goto(HTML_DIR + "/images.html")
  end

  describe "#length" do
    it "returns the number of maps" do
      @browser.maps.length.should == 2
    end
  end

  describe "#[]" do
    it "returns the p at the given index" do
      @browser.maps[1].id.should == "triangle_map"
    end
  end

  describe "#each" do
    it "iterates through maps correctly" do
      @browser.maps.each_with_index do |m, index|
        m.name.should == @browser.map(:index, index+1).name
        m.id.should == @browser.map(:index, index+1).id
        m.value.should == @browser.map(:index, index+1).value
      end
    end
  end

  after :all do
    @browser.close
  end

end

