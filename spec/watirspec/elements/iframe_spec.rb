require 'watirspec_helper'

#
# TODO: fix duplication with frame_spec
#

describe 'IFrame' do
  before :each do
    browser.goto(WatirSpec.url_for('iframes.html'))
  end

  not_compliant_on :safari do
    bug 'Firefox 58 broke this, appears to be working in Nightly',
        %i[firefox linux], %i[firefox appveyor] do
      it 'handles crossframe javascript' do
        browser.goto WatirSpec.url_for('iframes.html')

        expect(browser.iframe(id: 'iframe_1').text_field(name: 'senderElement').value).to eq 'send_this_value'
        expect(browser.iframe(id: 'iframe_2').text_field(name: 'recieverElement').value).to eq 'old_value'
        browser.iframe(id: 'iframe_1').button(id: 'send').click
        expect(browser.iframe(id: 'iframe_2').text_field(name: 'recieverElement').value).to eq 'send_this_value'
      end
    end
  end

  it 'locates an element defined by Selenium Element' do
    iframe = browser.iframe(id: 'iframe_1').locate
    se_element = iframe.instance_variable_get('@element')
    iframe2 = browser.element(element: se_element).to_subtype
    expect(iframe2).to eq iframe
  end

  describe '#wd' do
    it 'returns a Watir::FramedDriver instance' do
      iframe = browser.iframe(id: 'iframe_1')
      expect(iframe.wd).to be_a(Watir::FramedDriver)
    end

    it 'properly delegates driver commands' do
      iframe = browser.iframe(id: 'iframe_1')
      expect(iframe.wd.title).to eq 'Iframes'
    end

    it 'properly delegates element commands' do
      iframe = browser.iframe(id: 'iframe_1')
      expect(iframe.wd.attribute('id')).to eq 'iframe_1'
    end
  end

  describe '#exist?' do
    it 'returns true if the iframe exists' do
      expect(browser.iframe(id: 'iframe_1')).to exist
      expect(browser.iframe(name: 'iframe1')).to exist
      expect(browser.iframe(index: 0)).to exist
      expect(browser.iframe(class: 'half')).to exist
      expect(browser.iframe(xpath: "//iframe[@id='iframe_1']")).to exist
      expect(browser.iframe(src: 'iframe_1.html')).to exist
      expect(browser.iframe(id: /iframe/)).to exist
      expect(browser.iframe(name: /iframe/)).to exist
      expect(browser.iframe(src: /iframe_1/)).to exist
      expect(browser.iframe(class: /half/)).to exist
    end

    it 'returns the first iframe if given no args' do
      expect(browser.iframe).to exist
    end

    it "returns false if the iframe doesn't exist" do
      expect(browser.iframe(id: 'no_such_id')).to_not exist
      expect(browser.iframe(name: 'no_such_text')).to_not exist
      expect(browser.iframe(index: 1337)).to_not exist
      expect(browser.iframe(src: 'no_such_src')).to_not exist
      expect(browser.iframe(class: 'no_such_class')).to_not exist
      expect(browser.iframe(id: /no_such_id/)).to_not exist
      expect(browser.iframe(name: /no_such_text/)).to_not exist
      expect(browser.iframe(src: /no_such_src/)).to_not exist
      expect(browser.iframe(class: /no_such_class/)).to_not exist
      expect(browser.iframe(xpath: "//iframe[@id='no_such_id']")).to_not exist
    end

    it 'returns false if an element in an iframe does exist' do
      expect(browser.iframe.element(css: '#senderElement')).to exist
      expect(browser.iframe.element(id: 'senderElement')).to exist
    end

    it 'returns true if an element in an iframe does not exist' do
      expect(browser.iframe.element(css: '#no_such_id')).to_not exist
      expect(browser.iframe.element(id: 'no_such_id')).to_not exist
    end

    it 'returns true if an element outside an iframe exists after checking for one inside that does exist' do
      existing_element = browser.element(css: '#iframe_1')
      expect(existing_element).to exist
      expect(browser.iframe.element(css: '#senderElement')).to exist
      expect(existing_element).to exist
    end

    it 'returns true if an element outside an iframe exists after checking for one inside that does not exist' do
      existing_element = browser.element(css: '#iframe_1')
      expect(existing_element).to exist
      expect(browser.iframe.element(css: '#no_such_id')).to_not exist
      expect(existing_element).to exist
    end

    it 'returns true if an element exists in a frame generated in a collection' do
      nested_element = browser.body.iframes.first.div
      expect(nested_element).to exist
    end

    it 'returns false for sub-element of a non-existing iframe' do
      expect(browser.iframe(id: 'no_such_id').element).to_not exist
    end

    bug 'https://bugzilla.mozilla.org/show_bug.cgi?id=1255946', :firefox do
      not_compliant_on :safari do
        it 'handles nested iframes' do
          browser.goto(WatirSpec.url_for('nested_iframes.html'))
          browser.iframe(id: 'two').iframe(id: 'three').link(id: 'four').click

          Watir::Wait.until { browser.title == 'definition_lists' }
        end
      end
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.iframe(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  it 'handles all locators for element which do not exist' do
    expect(browser.iframe(index: 0).div(id: 'invalid')).to_not exist
  end

  describe '#present?' do
    it 'returns true if the iframe present' do
      expect(browser.iframe(id: 'iframe_1')).to be_present
    end

    it 'returns false if the iframe is not present' do
      expect(browser.iframe(id: 'no_such_id')).not_to be_present
    end
  end

  it 'switches between iframe and parent when needed' do
    browser.iframe(id: 'iframe_1').elements.each do |element|
      element.text
      browser.h1.text
    end
  end

  it 'switches when the frame is created by subtype' do
    subtype = browser.iframe.to_subtype
    expect { subtype.element.locate }.to_not raise_exception
  end

  it 'switches back to top level browsing context' do
    # Point driver to browsing context of first iframe
    browser.iframes.first.ps.locate

    expect(browser.h1s.first.text).to be == 'Iframes'
  end

  it 'raises UnknownFrameException when accessing elements inside non-existing iframe' do
    expect { browser.iframe(name: 'no_such_name').p(index: 0).id }.to raise_unknown_frame_exception
  end

  it 'raises UnknownFrameException when accessing a non-existing iframe' do
    expect { browser.iframe(name: 'no_such_name').id }.to raise_unknown_frame_exception
  end

  it 'raises UnknownFrameException when accessing a non-existing subframe' do
    expect { browser.iframe(name: 'iframe1').iframe(name: 'no_such_name').id }.to raise_unknown_frame_exception
  end

  it 'raises UnknownObjectException when accessing a non-existing element inside an existing iframe' do
    expect { browser.iframe(index: 0).p(index: 1337).id }.to raise_unknown_object_exception
  end

  it "raises NoMethodError when trying to access attributes it doesn't have" do
    expect { browser.iframe(index: 0).foo }.to raise_error(NoMethodError)
  end

  it 'is able to set a field' do
    browser.iframe(index: 0).text_field(name: 'senderElement').set('new value')
    expect(browser.iframe(index: 0).text_field(name: 'senderElement').value).to eq 'new value'
  end

  it 'will suggest looking in an iframe when iframes exist' do
    msg = 'Maybe look in an iframe?'
    expect { browser.text_field(name: 'senderElement').set('no') }.to raise_unknown_object_exception(msg)
  end

  it 'will suggest looking in a nested iframe when iframes exist' do
    browser.goto(WatirSpec.url_for('nested_iframes.html'))
    top = browser.iframe(id: 'two')
    expect { top.link(id: 'four').click }.to raise_unknown_object_exception('Maybe look in an iframe?')
  end

  describe '#execute_script' do
    bug 'Safari does not strip text', :safari do
      it 'executes the given javascript in the specified frame' do
        frame = browser.iframe(index: 0)
        expect(frame.div(id: 'set_by_js').text).to eq ''
        inner_html = 'Art consists of limitation. The most beautiful part of every picture is the frame.'
        script = "document.getElementById('set_by_js').innerHTML = '#{inner_html}'"
        frame.execute_script script
        text = 'Art consists of limitation. The most beautiful part of every picture is the frame.'
        expect(frame.div(id: 'set_by_js').text).to eq text
      end
    end
  end

  describe '#html' do
    it 'returns the full HTML source of the iframe' do
      browser.goto WatirSpec.url_for('iframes.html')
      expect(browser.iframe.html.downcase).to include('<title>iframe 1</title>')
    end
  end

  describe '#text' do
    it 'returns the text inside the iframe' do
      browser.goto WatirSpec.url_for('iframes.html')
      expect(browser.iframe.text).to include('Frame 1')
    end
  end
end

describe 'FramedDriver' do
  it 'raises name error if method is not defined on driver or element' do
    browser.goto WatirSpec.url_for('iframes.html')
    expect(browser.iframe(id: 'iframe_1').wd).not_to respond_to :foo
    expect { browser.iframe(id: 'iframe_1').wd.foo }.to raise_exception NoMethodError
  end

  it 'raises exception when attempting to switch to a non-frame element' do
    browser.goto WatirSpec.url_for('iframes.html')
    element = browser.h1.wd
    fd = Watir::FramedDriver.new(element, browser)
    expect { fd.switch! }.to raise_exception Watir::Exception::UnknownFrameException
  end
end
