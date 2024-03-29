# frozen_string_literal: true

require 'watirspec_helper'

#
# TODO: fix duplication with iframe_spec
#

module Watir
  describe Frame do
    before do
      browser.goto(WatirSpec.url_for('frames.html'))
    end

    it 'handles crossframe javascript' do
      expect(browser.frame(id: 'frame_1').text_field(name: 'senderElement').value).to eq 'send_this_value'
      expect(browser.frame(id: 'frame_2').text_field(name: 'recieverElement').value).to eq 'old_value'
      browser.frame(id: 'frame_1').button(id: 'send').click
      expect(browser.frame(id: 'frame_2').text_field(name: 'recieverElement').value).to eq 'send_this_value'
    end

    describe '#exist?' do
      it 'returns true if the frame exists' do
        expect(browser.frame(id: 'frame_1')).to exist
        expect(browser.frame(name: 'frame1')).to exist
        expect(browser.frame(index: 0)).to exist
        expect(browser.frame(class: 'half')).to exist
        expect(browser.frame(xpath: "//frame[@id='frame_1']")).to exist
        expect(browser.frame(src: 'frame_1.html')).to exist
        expect(browser.frame(id: /frame/)).to exist
        expect(browser.frame(name: /frame/)).to exist
        expect(browser.frame(src: /frame_1/)).to exist
        expect(browser.frame(class: /half/)).to exist
      end

      it 'returns the first frame if given no args' do
        expect(browser.frame).to exist
      end

      it "returns false if the frame doesn't exist" do
        expect(browser.frame(id: 'no_such_id')).not_to exist
        expect(browser.frame(name: 'no_such_text')).not_to exist
        expect(browser.frame(index: 1337)).not_to exist
        expect(browser.frame(src: 'no_such_src')).not_to exist
        expect(browser.frame(class: 'no_such_class')).not_to exist
        expect(browser.frame(id: /no_such_id/)).not_to exist
        expect(browser.frame(name: /no_such_text/)).not_to exist
        expect(browser.frame(src: /no_such_src/)).not_to exist
        expect(browser.frame(class: /no_such_class/)).not_to exist
        expect(browser.frame(xpath: "//frame[@id='no_such_id']")).not_to exist
      end

      it 'handles nested frames' do
        browser.goto(WatirSpec.url_for('nested_frames.html'))

        browser.frame(id: 'two').frame(id: 'three').link(id: 'four').click

        browser.wait_until(title: 'definition_lists')
        expect { browser.goto(WatirSpec.url_for('nested_frames.html')) }.not_to raise_exception
      end

      it "raises TypeError when 'what' argument is invalid" do
        expect { browser.frame(id: 3.14).exists? }.to raise_error(TypeError)
      end
    end

    it 'raises UnknownFrameException when accessing elements inside non-existing frame' do
      expect { browser.frame(name: 'no_such_name').p(index: 0).id }.to raise_unknown_frame_exception
    end

    it 'raises UnknownFrameException when accessing a non-existing frame' do
      expect { browser.frame(name: 'no_such_name').id }.to raise_unknown_frame_exception
    end

    it 'raises UnknownFrameException when accessing a non-existing subframe' do
      expect { browser.frame(name: 'frame1').frame(name: 'no_such_name').id }.to raise_unknown_frame_exception
    end

    it 'raises UnknownObjectException when accessing a non-existing element inside an existing frame' do
      expect { browser.frame(index: 0).p(index: 1337).id }.to raise_unknown_object_exception
    end

    it "raises NoMethodError when trying to access attributes it doesn't have" do
      expect { browser.frame(index: 0).foo }.to raise_error(NoMethodError)
    end

    it 'is able to set a field' do
      browser.frame(index: 0).text_field(name: 'senderElement').set('new value')
      expect(browser.frame(index: 0).text_field(name: 'senderElement').value).to eq 'new value'
    end

    it "can access the frame's parent element after use" do
      el = browser.frameset
      el.frame.text_field.value
      expect(el.attribute_value('cols')).to be_a(String)
    end

    describe '#execute_script' do
      it 'executes the given javascript in the specified frame',
         except: {browser: :safari, reason: 'Safari does not strip text'} do
        frame = browser.frame(index: 0)
        expect(frame.div(id: 'set_by_js').text).to eq ''
        inner_html = 'Art consists of limitation. The most beautiful part of every picture is the frame.'
        frame.execute_script(%{document.getElementById('set_by_js').innerHTML = '#{inner_html}'})
        text = 'Art consists of limitation. The most beautiful part of every picture is the frame.'
        expect(frame.div(id: 'set_by_js').text).to eq text
      end
    end

    describe '#html' do
      it 'returns the full HTML source of the frame' do
        browser.goto WatirSpec.url_for('frames.html')
        expect(browser.frame.html.downcase).to include('<title>frame 1</title>')
      end
    end
  end
end
