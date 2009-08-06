require File.dirname(__FILE__) + '/spec_helper.rb'

describe "Spans" do

  before :all do
    @browser = Browser.new(BROWSER_OPTIONS)
  end

  before :each do
    @browser.goto(WatirSpec.files + "/non_control_elements.html")
  end

  describe "#length" do
    it "returns the number of spans" do
      @browser.spans.length.should == 6
    end
  end

  describe "#[]" do
    it "returns the p at the given index" do
      @browser.spans[1].id.should == "lead"
    end
  end

  describe "#each" do
    it "iterates through spans correctly" do
      @browser.spans.each_with_index do |s, index|
        s.name.should == @browser.span(:index, index+1).name
        s.id.should == @browser.span(:index, index+1).id
        s.value.should == @browser.span(:index, index+1).value
      end
    end
  end

  describe "#to_s" do
    it "returns a human readable representation of the collection" do
      @browser.spans.to_s.should == "tag:          span\n" +
                              "  id:           lead\n" +
                              "  class:        lead\n" +
                              "  title:        Lorem ipsum\n" +
                              "  text:         Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Curabitur eu pede. Ut justo. Praesent feugiat, elit in feugiat iaculis, sem risus rutrum justo, eget fermentum dolor arcu non nunc.\n" +
                              "tag:          span\n" +
                              "  name:         invalid_attribute\n" +
                              "  value:        invalid_attribute\n" +
                              "  text:         Sed pretium metus et quam. Nullam odio dolor, vestibulum non, tempor ut, vehicula sed, sapien. Vestibulum placerat ligula at quam. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.\n" +
                              "tag:          span\n" +
                              "  text:         Suspendisse at ipsum a turpis viverra venenatis. Praesent ut nibh. Nullam eu odio. Donec tempor, elit ut lacinia porttitor, augue neque vehicula diam, in elementum ligula nisi a tellus. Aliquam vestibulum ultricies tortor.\n" +
                              "tag:          span\n" +
                              "  text:         Dubito, ergo cogito, ergo sum.\n" +
                              "tag:          span\n" +
                              "tag:          span\n" +
                              "  class:        footer\n" +
                              "  name:         footer\n" +
                              "  onclick:      this.innerHTML = 'This is a footer with text set by Javascript.'\n" +
                              "  text:         This is a footer."
    end
  end

  after :all do
    @browser.close
  end

end

