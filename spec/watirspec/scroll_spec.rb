# frozen_string_literal: true

require 'watirspec_helper'

describe Watir::Scrolling do
  before(:each) do
    browser.goto(WatirSpec.url_for('scroll.html'))
    pause
  end

  def top_centered_viewport
    browser.execute_script('return (window.innerHeight - document.body.scrollHeight)/2;')
  end

  def current_top
    browser.execute_script('return document.body.getBoundingClientRect().top;')
  end

  context 'when scrolling Browser' do
    describe '#to' do
      it 'scrolls to the top of the page' do
        browser.scroll.to :bottom
        expect(browser.div(id: 'top')).not_to be_in_viewport
        browser.scroll.to :top
        expect(browser.div(id: 'top')).to be_in_viewport
      end

      it 'scrolls to the center of the page' do
        browser.scroll.to :center
        viewport_top = browser.execute_script('return document.body.getBoundingClientRect().top;')

        expect(viewport_top).to be_within(1).of(top_centered_viewport)
      end

      it 'scrolls to the bottom of the page' do
        expect(browser.div(id: 'bottom')).not_to be_in_viewport
        browser.scroll.to :bottom
        expect(browser.div(id: 'bottom')).to be_in_viewport
      end

      it 'scrolls to coordinates' do
        element = browser.div(id: 'center')
        location = element.location
        browser.scroll.to [location.x, location.y]
        expect(element).to be_in_viewport
      end

      it 'raises error when scroll point is not valid' do
        expect { browser.scroll.to(:blah) }.to raise_error(ArgumentError)
      end
    end

    describe '#by' do
      before do
        browser.scroll.to :top
        pause
      end

      it 'offset from top' do
        initial_top = current_top
        scroll_by = top_centered_viewport.round
        browser.scroll.by(0, -scroll_by)
        pause
        puts "scroll by #{scroll_by}"
        puts "initial top #{initial_top}"
        puts "current top #{current_top}"
        expect(current_top).to be_within(1).of(scroll_by + initial_top)
      end

      it 'offset from bottom' do
        initial_top = current_top
        browser.scroll.to :bottom
        scroll_by = top_centered_viewport
        browser.scroll.by(0, scroll_by)
        pause
        expect(current_top).to be_within(1).of(scroll_by + initial_top)
      end
    end

    describe '#from' do
      it 'scrolls by given amount with offset' do
        browser.goto(WatirSpec.url_for('scroll_nested.html'))

        browser.scroll.from(10, 10).by(0, 225)

        expect(in_viewport?(browser.iframe.checkbox(name: 'scroll_checkbox'))).to eq true
      end
    end
  end

  context 'when scrolling Element' do
    describe '#to' do
      it 'scrolls element into view (viewport)',
         except: {browser: %i[firefox safari], reason: 'incorrect MoveTargetOutOfBoundsError'} do
        browser.goto(WatirSpec.url_for('scroll_nested_offscreen.html'))
        iframe = browser.iframe

        expect(in_viewport?(iframe)).to eq false

        iframe.scroll.to(:viewport)

        expect(in_viewport?(iframe)).to eq true
      end

      it 'scrolls to element (top) by default' do
        element = browser.div(id: 'center')
        element.scroll.to

        element_top = browser.execute_script('return arguments[0].getBoundingClientRect().top', element)
        expect(element_top).to be_within(1).of(0)
      end

      it 'scrolls to element (center)' do
        element = browser.div(id: 'center')
        element.scroll.to :center

        element_rect = browser.execute_script('return arguments[0].getBoundingClientRect()', element)

        expect(element_rect['top']).to eq(element_rect['bottom'] - element_rect['height'])
      end

      it 'scrolls to element (bottom)' do
        element = browser.div(id: 'center')
        element.scroll.to :bottom

        element_bottom = browser.execute_script('return arguments[0].getBoundingClientRect().bottom', element)
        window_height = browser.execute_script('return window.innerHeight')

        expect(element_bottom).to be_within(1).of(window_height)
      end

      it 'scrolls to element multiple times' do
        2.times do
          element = browser.div(id: 'center')
          element.scroll.to(:center)

          element_rect = browser.execute_script('return arguments[0].getBoundingClientRect()', element)

          expect(element_rect['top']).to eq(element_rect['bottom'] - element_rect['height'])
        end
      end

      it 'raises error when scroll param is not valid' do
        expect { browser.div(id: 'top').scroll.to(:blah) }.to raise_error(ArgumentError)
      end
    end

    describe '#by' do
      it 'offset' do
        browser.scroll.to :top
        pause
        initial_top = current_top
        browser.scroll.to :bottom
        pause
        scroll_by = top_centered_viewport

        element = browser.div(id: 'bottom')
        element.scroll.by(0, scroll_by)
        pause
        expect(current_top).to be_within(1).of(scroll_by + initial_top)
      end
    end

    describe '#from',
             except: {browser: %i[firefox safari], reason: 'incorrect MoveTargetOutOfBoundsError'} do
      it 'scrolls from element by given amount' do
        browser.goto(WatirSpec.url_for('scroll_nested_offscreen.html'))
        iframe = browser.iframe

        iframe.scroll.from.by(0, 200)

        checkbox = iframe.checkbox(name: 'scroll_checkbox')
        expect(in_viewport?(checkbox)).to eq true
      end

      it 'scrolls from an element with an offset' do
        browser.goto(WatirSpec.url_for('scroll_nested_offscreen.html'))

        move_left = browser.execute_script('return arguments[0].getBoundingClientRect().width/2', browser.footer) -
                    browser.execute_script('return arguments[0].getBoundingClientRect().right/2', browser.iframe.we)

        browser.footer.scroll.from(-move_left.round, -50).by(0, 200)

        checkbox = browser.iframe.checkbox(name: 'scroll_checkbox')
        expect(in_viewport?(checkbox)).to eq true
      end
    end
  end

  def in_viewport?(element)
    in_viewport = <<~IN_VIEWPORT
      for(var e=arguments[0],f=e.offsetTop,t=e.offsetLeft,o=e.offsetWidth,n=e.offsetHeight;
      e.offsetParent;)f+=(e=e.offsetParent).offsetTop,t+=e.offsetLeft;
      return f<window.pageYOffset+window.innerHeight&&t<window.pageXOffset+window.innerWidth&&f+n>
      window.pageYOffset&&t+o>window.pageXOffset
    IN_VIEWPORT

    element.browser.execute_script(in_viewport, element.we)
  end

  def pause
    sleep 0.2
  end
end
