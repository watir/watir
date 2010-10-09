# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

bug "http://github.com/jarib/watir-webdriver/issues#issue/17", :webdriver do

  describe "<frame> Frames" do

    before :each do
      browser.goto(WatirSpec.files + "/frames.html")
    end

    bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
      describe "with selectors" do
        it "returns the matching elements" do
          browser.frames(:name => "frame1").to_a.should == [browser.frame(:class => "frame1")]
        end
      end
    end
    
    describe "#length" do
      it "returns the correct number of frames" do
        browser.frames.length.should == 2
      end
    end

    describe "#[]" do
      it "returns the frame at the given index" do
        browser.frames[0].id.should == "frame_1"
      end
    end

    describe "#each" do
      it "iterates through frames correctly" do
        count = 0

        browser.frames.each_with_index do |f, index|
          f.id.should ==  browser.frame(:index, index).id
          f.value.should == browser.frame(:index, index).value

          count += 1
        end

        count.should > 0
      end
    end
  end

  describe "<iframe> Frames" do

    before :each do
      browser.goto(WatirSpec.files + "/iframes.html")
    end

    describe "#length" do
      it "returns the correct number of frames" do
        browser.frames.length.should == 2
      end
    end

    describe "#[]" do
      it "returns the frame at the given index" do
        browser.frames[0].id.should == "frame_1"
      end
    end

    describe "#each" do
      it "iterates through frames correctly" do
        count = 0

        browser.frames.each_with_index do |f, index|
          f.name.should == browser.frame(:index, index).name
          f.id.should ==  browser.frame(:index, index).id
          f.value.should == browser.frame(:index, index).value

          count += 1
        end

        count.should > 0
      end
    end
  end

end