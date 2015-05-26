# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

#
# TODO: fix duplication with iframe_spec
#

describe "Frame" do

  before :each do
    browser.goto(WatirSpec.url_for("frames.html"))
  end

  it "handles crossframe javascript" do
    browser.goto WatirSpec.url_for("frames.html", needs_server: true)

    expect(browser.frame(id: "frame_1").text_field(name: 'senderElement').value).to eq 'send_this_value'
    expect(browser.frame(id: "frame_2").text_field(name: 'recieverElement').value).to eq 'old_value'
    browser.frame(id: "frame_1").button(id: 'send').click
    expect(browser.frame(id: "frame_2").text_field(name: 'recieverElement').value).to eq 'send_this_value'
  end

  describe "#exist?" do
    it "returns true if the frame exists" do
      expect(browser.frame(id: "frame_1")).to exist
      expect(browser.frame(name: "frame1")).to exist
      expect(browser.frame(index: 0)).to exist
      expect(browser.frame(class: "half")).to exist
      not_compliant_on %i(watir_classic internet_explorer10) do
        expect(browser.frame(xpath: "//frame[@id='frame_1']")).to exist
      end
      not_compliant_on :watir_classic do
        expect(browser.frame(src: "frame_1.html")).to exist
      end
      expect(browser.frame(id: /frame/)).to exist
      expect(browser.frame(name: /frame/)).to exist
      expect(browser.frame(src: /frame_1/)).to exist
      expect(browser.frame(class: /half/)).to exist
    end

    it "returns the first frame if given no args" do
      expect(browser.frame).to exist
    end

    it "returns false if the frame doesn't exist" do
      expect(browser.frame(id: "no_such_id")).to_not exist
      expect(browser.frame(name: "no_such_text")).to_not exist
      expect(browser.frame(index: 1337)).to_not exist

      expect(browser.frame(src: "no_such_src")).to_not exist
      expect(browser.frame(class: "no_such_class")).to_not exist
      expect(browser.frame(id: /no_such_id/)).to_not exist
      expect(browser.frame(name: /no_such_text/)).to_not exist
      expect(browser.frame(src: /no_such_src/)).to_not exist
      expect(browser.frame(class: /no_such_class/)).to_not exist
      expect(browser.frame(xpath: "//frame[@id='no_such_id']")).to_not exist
    end

    bug "https://github.com/detro/ghostdriver/issues/159", :phantomjs do
      it "handles nested frames" do
        browser.goto(WatirSpec.url_for("nested_frames.html", needs_server: true))

        browser.frame(id: "two").frame(id: "three").link(id: "four").click

        Wait.until{ browser.title == "definition_lists" }
      end
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.frame(id: 3.14).exists? }.to raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      expect { browser.frame(no_such_how: 'some_value').exists? }.to raise_error(Watir::Exception::MissingWayOfFindingObjectException)
    end
  end

  it "raises UnknownFrameException when accessing elements inside non-existing frame" do
    expect { browser.frame(name: "no_such_name").p(index: 0).id }.to raise_error(Watir::Exception::UnknownFrameException)
  end

  it "raises UnknownFrameException when accessing a non-existing frame" do
    expect { browser.frame(name: "no_such_name").id }.to raise_error(Watir::Exception::UnknownFrameException)
  end

  it "raises UnknownFrameException when accessing a non-existing subframe" do
    expect { browser.frame(name: "frame1").frame(name: "no_such_name").id }.to raise_error(Watir::Exception::UnknownFrameException)
  end

  it "raises UnknownObjectException when accessing a non-existing element inside an existing frame" do
    expect { browser.frame(index: 0).p(index: 1337).id }.to raise_error(Watir::Exception::UnknownObjectException)
  end

  it "raises NoMethodError when trying to access attributes it doesn't have" do
    expect { browser.frame(index: 0).foo }.to raise_error(NoMethodError)
  end

  it "is able to set a field" do
    browser.frame(index: 0).text_field(name: 'senderElement').set("new value")
    expect(browser.frame(index: 0).text_field(name: 'senderElement').value).to eq "new value"
  end

  it "can access the frame's parent element after use" do
    el = browser.frameset
    el.frame.text_field.value
    expect(el.attribute_value("cols")).to be_kind_of(String)
  end

  describe "#execute_script" do
    it "executes the given javascript in the specified frame" do
      frame = browser.frame(index: 0)
      expect(frame.div(id: 'set_by_js').text).to eq ""
      frame.execute_script(%Q{document.getElementById('set_by_js').innerHTML = 'Art consists of limitation. The most beautiful part of every picture is the frame.'})
      expect(frame.div(id: 'set_by_js').text).to eq "Art consists of limitation. The most beautiful part of every picture is the frame."
    end
  end

  describe "#html" do
    not_compliant_on %i(webdriver iphone) do
      it "returns the full HTML source of the frame" do
        browser.goto WatirSpec.url_for("frames.html")
        expect(browser.frame.html.downcase).to include("<title>frame 1</title>")
      end
    end
  end

end
