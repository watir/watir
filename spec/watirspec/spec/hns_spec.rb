require File.dirname(__FILE__) + '/spec_helper.rb'

describe "H1s", "H2s", "H3s", "H4s", "H5s", "H6s" do

  before :all do
    @browser = Browser.new(BROWSER_OPTIONS)
  end

  before :each do
    @browser.goto(WatirSpec.files + "/non_control_elements.html")
  end

  describe "#length" do
    it "returns the number of h1s" do
      @browser.h2s.length.should == 9
    end
  end

  describe "#[]" do
    it "returns the h1 at the given index" do
      @browser.h1s[1].id.should == "first_header"
    end
  end

  describe "#each" do
    it "iterates through header collections correctly" do
      lengths = (1..6).collect do |i|
        collection = @browser.send(:"h#{i}s")
        collection.each_with_index do |h, index|
          h.name.should == @browser.send(:"h#{i}", :index, index+1).name
          h.id.should == @browser.send(:"h#{i}", :index, index+1).id
          h.value.should == @browser.send(:"h#{i}", :index, index+1).value
        end
        collection.length
      end
      lengths.should == [2, 9, 2, 1, 1, 2]
    end
  end

  after :all do
    @browser.close
  end

end

