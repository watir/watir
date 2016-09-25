# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

#
# TODO: fix duplication with frame_spec
#

describe "IFrame" do

  before :each do
    browser.goto(WatirSpec.url_for("iframes.html"))
  end

  bug "https://bugzilla.mozilla.org/show_bug.cgi?id=1255906", :firefox do
    it "handles crossframe javascript" do
      browser.goto WatirSpec.url_for("iframes.html", needs_server: true)

      expect(browser.iframe(id: "iframe_1").text_field(name: 'senderElement').value).to eq 'send_this_value'
      expect(browser.iframe(id: "iframe_2").text_field(name: 'recieverElement').value).to eq 'old_value'
      browser.iframe(id: "iframe_1").button(id: 'send').click
      expect(browser.iframe(id: "iframe_2").text_field(name: 'recieverElement').value).to eq 'send_this_value'
    end
  end

  describe "#exist?" do
    it "returns true if the iframe exists" do
      expect(browser.iframe(id: "iframe_1")).to exist
      expect(browser.iframe(name: "iframe1")).to exist
      expect(browser.iframe(index: 0)).to exist
      expect(browser.iframe(class: "half")).to exist
      expect(browser.iframe(xpath: "//iframe[@id='iframe_1']")).to exist
      expect(browser.iframe(src: "iframe_1.html")).to exist
      expect(browser.iframe(id: /iframe/)).to exist
      expect(browser.iframe(name: /iframe/)).to exist
      expect(browser.iframe(src: /iframe_1/)).to exist
      expect(browser.iframe(class: /half/)).to exist
    end

    it "returns the first iframe if given no args" do
      expect(browser.iframe).to exist
    end

    it "returns false if the iframe doesn't exist" do
      expect(browser.iframe(id: "no_such_id")).to_not exist
      expect(browser.iframe(name: "no_such_text")).to_not exist
      expect(browser.iframe(index: 1337)).to_not exist
      expect(browser.iframe(src: "no_such_src")).to_not exist
      expect(browser.iframe(class: "no_such_class")).to_not exist
      expect(browser.iframe(id: /no_such_id/)).to_not exist
      expect(browser.iframe(name: /no_such_text/)).to_not exist
      expect(browser.iframe(src: /no_such_src/)).to_not exist
      expect(browser.iframe(class: /no_such_class/)).to_not exist
      expect(browser.iframe(xpath: "//iframe[@id='no_such_id']")).to_not exist
    end

    it "returns false if an element in an iframe does exist" do
      expect(browser.iframe.element(css: "#senderElement")).to exist
      expect(browser.iframe.element(id: "senderElement")).to exist
    end

    it "returns true if an element in an iframe does not exist" do
      expect(browser.iframe.element(css: "#no_such_id")).to_not exist
      expect(browser.iframe.element(id: "no_such_id")).to_not exist
    end

    it "returns true if an element outside an iframe exists after checking for one inside that does exist" do
      existing_element = browser.element(css: "#iframe_1")
      expect(existing_element).to exist
      expect(browser.iframe.element(css: "#senderElement")).to exist
      expect(existing_element).to exist
    end

    it "returns true if an element outside an iframe exists after checking for one inside that does not exist" do
      existing_element = browser.element(css: "#iframe_1")
      expect(existing_element).to exist
      expect(browser.iframe.element(css: "#no_such_id")).to_not exist
      expect(existing_element).to exist
    end

    it "returns true if an element exists in a frame generated in a collection" do
      nested_element = browser.body.iframes.first.div
      expect(nested_element).to exist
    end


    bug "https://github.com/detro/ghostdriver/issues/159", :phantomjs do
      bug "https://bugzilla.mozilla.org/show_bug.cgi?id=1255946", :firefox do
        it "handles nested iframes" do
          browser.goto(WatirSpec.url_for("nested_iframes.html"))

          browser.iframe(id: "two").iframe(id: "three").link(id: "four").click

          Wait.until { browser.title == "definition_lists" }
        end
      end
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.iframe(id: 3.14).exists? }.to raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      expect { browser.iframe(no_such_how: 'some_value').exists? }.to raise_error(Watir::Exception::MissingWayOfFindingObjectException)
    end
  end

  it 'handles all locators for element which do not exist' do
    expect(browser.iframe(index: 0).div(id: 'invalid')).to_not exist
  end

  it 'switches between iframe and parent when needed' do
    browser.iframe(id: "iframe_1").elements.each do |element|
      element.text
      browser.h1.text
    end
  end

  it 'switches back to top level browsing context' do
    # Point driver to browsing context of first iframe
    browser.iframes.first.ps.to_a

    expect(browser.h1s.first.text).to be == 'Iframes'
  end

  it "raises UnknownFrameException when accessing elements inside non-existing iframe" do
    expect { browser.iframe(name: "no_such_name").p(index: 0).id }.to raise_error(Watir::Exception::UnknownFrameException)
  end

  it "raises UnknownFrameException when accessing a non-existing iframe" do
    expect { browser.iframe(name: "no_such_name").id }.to raise_error(Watir::Exception::UnknownFrameException)
  end

  it "raises UnknownFrameException when accessing a non-existing subframe" do
    expect { browser.iframe(name: "iframe1").iframe(name: "no_such_name").id }.to raise_error(Watir::Exception::UnknownFrameException)
  end

  it "raises UnknownObjectException when accessing a non-existing element inside an existing iframe" do
    expect { browser.iframe(index: 0).p(index: 1337).id }.to raise_error(Watir::Exception::UnknownObjectException)
  end

  it "raises NoMethodError when trying to access attributes it doesn't have" do
    expect { browser.iframe(index: 0).foo }.to raise_error(NoMethodError)
  end

  bug "https://bugzilla.mozilla.org/show_bug.cgi?id=1255906", :firefox do
    it "is able to set a field" do
      browser.iframe(index: 0).text_field(name: 'senderElement').set("new value")
      expect(browser.iframe(index: 0).text_field(name: 'senderElement').value).to eq "new value"
    end
  end

  describe "#execute_script" do
    it "executes the given javascript in the specified frame" do
      frame = browser.iframe(index: 0)
      expect(frame.div(id: 'set_by_js').text).to eq ""
      frame.execute_script(%Q{document.getElementById('set_by_js').innerHTML = 'Art consists of limitation. The most beautiful part of every picture is the frame.'})
      expect(frame.div(id: 'set_by_js').text).to eq "Art consists of limitation. The most beautiful part of every picture is the frame."
    end
  end

  describe "#html" do
    it "returns the full HTML source of the iframe" do
      browser.goto WatirSpec.url_for("iframes.html")
      expect(browser.iframe.html.downcase).to include("<title>iframe 1</title>")
    end
  end

  describe "#text" do
    it "returns the text inside the iframe" do
      browser.goto WatirSpec.url_for("iframes.html")
      expect(browser.iframe.text).to include("Frame 1")
    end
  end

end
