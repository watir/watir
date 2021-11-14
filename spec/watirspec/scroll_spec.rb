require 'watirspec_helper'

describe Watir::Scrolling do
  before(:each) do
    browser.goto(WatirSpec.url_for('scroll.html'))
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
        sleep(0.1)
        browser.scroll.to :top
      end

      it 'offset from top' do
        initial_top = current_top
        scroll_by = top_centered_viewport
        browser.scroll.by(0, -scroll_by)

        expect(current_top).to be_within(1).of(scroll_by + initial_top)
      end

      it 'offset from bottom' do
        browser.scroll.to :top
        initial_top = current_top
        browser.scroll.to :bottom
        scroll_by = top_centered_viewport
        browser.scroll.by(0, scroll_by)

        expect(current_top).to be_within(1).of(scroll_by + initial_top)
      end
    end
  end

  context 'when scrolling Element' do
    describe '#to' do
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
        sleep 0.1
        browser.scroll.to :top
        initial_top = current_top
        browser.scroll.to :bottom
        scroll_by = top_centered_viewport

        element = browser.div(id: 'bottom')
        element.scroll.by(0, scroll_by)

        expect(current_top).to be_within(1).of(scroll_by + initial_top)
      end
    end
  end
end
