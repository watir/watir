# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Frame" do

  before :each do
   browser.goto(WatirSpec.files + "/frames.html")
  end

  it "handles crossframe javascript" do
    browser.frame(:id, "frame_1").text_field(:name, 'senderElement').value.should == 'send_this_value'
    browser.frame(:id, "frame_2").text_field(:name, 'recieverElement').value.should == 'old_value'
    browser.frame(:id, "frame_1").button(:id, 'send').click
    browser.frame(:id, "frame_2").text_field(:name, 'recieverElement').value.should == 'send_this_value'
  end

  not_compliant_on :watir do
    describe "#exist?" do
      it "returns true if the frame exists" do
        browser.frame(:id, "frame_1").should exist
        browser.frame(:id, /frame/).should exist
        browser.frame(:name, "frame1").should exist
        browser.frame(:name, /frame/).should exist
        browser.frame(:src, "frame_1.html").should exist
        browser.frame(:src, /frame_1/).should exist
        browser.frame(:class, "half").should exist
        browser.frame(:class, /half/).should exist
        browser.frame(:index, 1).should exist
        browser.frame(:xpath, "//frame[@id='frame_1']").should exist
      end

      it "returns true if the iframe exists" do
        browser.goto(WatirSpec.files + "/iframes.html")
        browser.frame(:id, "frame_1").should exist
        browser.frame(:id, /frame/).should exist
        browser.frame(:name, "frame1").should exist
        browser.frame(:name, /frame/).should exist
        browser.frame(:src, "frame_1.html").should exist
        browser.frame(:src, /frame_1/).should exist
        browser.frame(:class, "iframe").should exist
        browser.frame(:class, /iframe/).should exist
        browser.frame(:index, 1).should exist
        browser.frame(:xpath, "//iframe[@id='frame_1']").should exist
      end

      it "returns true if the element exists (default how = :name)" do
        browser.frame("frame1").should exist
        browser.goto(WatirSpec.files + "/iframes.html")
        browser.frame("frame1").should exist
      end

      it "returns the first frame if given no args" do
        browser.frame.should exist
      end

      it "returns false if the frame doesn't exist" do
        browser.frame(:id, "no_such_id").should_not exist
        browser.frame(:id, /no_such_id/).should_not exist
        browser.frame(:name, "no_such_text").should_not exist
        browser.frame(:name, /no_such_text/).should_not exist
        browser.frame(:src, "no_such_src").should_not exist
        browser.frame(:src, /no_such_src/).should_not exist
        browser.frame(:class, "no_such_class").should_not exist
        browser.frame(:class, /no_such_class/).should_not exist
        browser.frame(:index, 1337).should_not exist
        browser.frame(:xpath, "//frame[@id='no_such_id']").should_not exist
      end

      it "raises TypeError when 'what' argument is invalid" do
        lambda { browser.frame(:id, 3.14).exists? }.should raise_error(TypeError)
      end

      it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
        lambda { browser.frame(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
      end
    end
  end

  it "raises UnknownFrameException when accessing elements inside non-existing frame" do
    lambda { browser.frame(:name, "no_such_name").p(:index, 1).id }.should raise_error(UnknownFrameException)
  end

  it "raises UnknownFrameException when accessing a non-existing frame" do
    lambda { browser.frame(:name, "no_such_name").id }.should raise_error(UnknownFrameException)
  end

  it "raises UnknownFrameException when accessing a non-existing subframe" do
    lambda { browser.frame(:name, "frame1").frame(:name, "no_such_name").id }.should raise_error(UnknownFrameException)
  end

  it "raises UnknownObjectException when accessing a non-existing element inside an existing frame" do
    lambda { browser.frame(:index, 1).p(:index, 1337).id }.should raise_error(UnknownObjectException)
  end

  it "raises NoMethodError when trying to access attributes it doesn't have" do
    lambda { browser.frame(:index, 1).foo }.should raise_error(NoMethodError)
  end

  it "is able to send a value to another frame by using Javascript" do
    frame1, frame2 = browser.frame(:index, 1), browser.frame(:index, 2)
    frame1.text_field(:index, 1).value.should == "send_this_value"
    frame2.text_field(:index, 1).value.should == "old_value"
    frame1.button(:index, 1).click
    frame2.text_field(:index, 1).value.should == "send_this_value"
  end

  it "is able to set a field" do
    browser.frame(:index, 1).text_field(:name, 'senderElement').set("new value")
    browser.frame(:index, 1).text_field(:name, 'senderElement').value.should == "new value"
  end

  describe "#contains_text" do
    it "finds text in a frame" do
      browser.frame(:name, 'frame1').contains_text('Suspendisse sit amet nisi.').should be_instance_of(Fixnum)
    end

    it "raises TypeError when given an invalid argument" do
      lambda { browser.frame(:name, 'frame1').contains_text(3.14) }.should raise_error(TypeError)
    end
  end


  not_compliant_on :watir do
    describe "#execute_script" do
      it "executes the given javascript in the specified frame" do
        frame = browser.frame(:index, 1)
        frame.div(:id, 'set_by_js').text.should == ""
        frame.execute_script(%Q{document.getElementById('set_by_js').innerHTML = 'Art consists of limitation. The most beautiful part of every picture is the frame.'})
        frame.div(:id, 'set_by_js').text.should == "Art consists of limitation. The most beautiful part of every picture is the frame."
      end
    end


    describe "#to_s" do
      it "returns a human readable representation of the frame" do
        browser.frame(:index, 1).to_s.should == "tag:          frame\n" +
                                            "  src:          frame_1.html\n" +
                                            "  id:           frame_1\n" +
                                            "  name:         frame1\n" +
                                            "  class:        half"
      end
    end

    describe "#elements_by_xpath" do
      before :each do
        browser.goto(WatirSpec.files + "/iframes.html")
      end

      it "returns an Array of matching elements" do
        objects = browser.frame(:index, 1).elements_by_xpath("/html")
        objects.size.should == 1
      end

      it "returns an empty Array if there are no matching elements" do
        objects = browser.frame(:index, 1).elements_by_xpath("//*[@type='foobar']")
        objects.size.should == 0
      end
    end

  end
end
