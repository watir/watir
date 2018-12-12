require 'watirspec_helper'

describe Watir::Scrolling do
  before(:each) do
    browser.goto(WatirSpec.url_for('scroll.html'))
  end

  def visible?(element)
    browser.execute_script('return isElementInViewport(arguments[0]);', element)
  end

  context 'when scrolling Browser' do
    describe '#to' do
      it 'scrolls to the top of the page' do
        browser.scroll.to :bottom
        browser.scroll.to :top
        expect(visible?(browser.button(text: 'Top'))).to eq(true)
        expect(visible?(browser.button(text: 'Center'))).to eq(true)
        expect(visible?(browser.button(text: 'Bottom'))).to eq(false)
      end

      it 'scrolls to the center of the page' do
        browser.scroll.to :center
        expect(visible?(browser.button(text: 'Top'))).to eq(false)
        expect(visible?(browser.button(text: 'Center'))).to eq(true)
        expect(visible?(browser.button(text: 'Bottom'))).to eq(false)
      end

      it 'scrolls to the bottom of the page' do
        browser.scroll.to :bottom
        expect(visible?(browser.button(text: 'Top'))).to eq(false)
        expect(visible?(browser.button(text: 'Center'))).to eq(true)
        expect(visible?(browser.button(text: 'Bottom'))).to eq(true)
      end

      it 'scrolls to coordinates' do
        button = browser.button(text: 'Bottom')
        browser.scroll.to [button.wd.location.x, button.wd.location.y]
        expect(visible?(button)).to eq(true)
      end

      it 'raises error when scroll point is not vaild' do
        expect { browser.scroll.to(:blah) }.to raise_error(ArgumentError)
      end
    end

    describe '#by' do
      it 'offset' do
        browser.scroll.to :bottom
        browser.scroll.by(-10_000, -10_000)

        expect(visible?(browser.button(text: 'Top'))).to eq(true)
        expect(visible?(browser.button(text: 'Center'))).to eq(true)
        expect(visible?(browser.button(text: 'Bottom'))).to eq(false)
      end
    end
  end

  context 'when scrolling Element' do
    describe '#to' do
      it 'scrolls to element (top)' do
        browser.button(text: 'Center').scroll.to
        expect(visible?(browser.button(text: 'Top'))).to eq(false)
        expect(visible?(browser.button(text: 'Center'))).to eq(true)
        expect(visible?(browser.button(text: 'Bottom'))).to eq(true)
      end

      it 'scrolls to element (center)' do
        browser.button(text: 'Center').scroll.to :center
        expect(visible?(browser.button(text: 'Top'))).to eq(false)
        expect(visible?(browser.button(text: 'Center'))).to eq(true)
        expect(visible?(browser.button(text: 'Bottom'))).to eq(false)
      end

      it 'scrolls to element (bottom)' do
        browser.button(text: 'Center').scroll.to :bottom
        expect(visible?(browser.button(text: 'Top'))).to eq(true)
        expect(visible?(browser.button(text: 'Center'))).to eq(true)
        expect(visible?(browser.button(text: 'Bottom'))).to eq(false)
      end

      it 'scrolls to element multiple times' do
        2.times do
          browser.button(text: 'Center').scroll.to(:center)
          expect(visible?(browser.button(text: 'Top'))).to eq(false)
        end
      end

      it 'raises error when scroll param is not vaild' do
        expect { browser.button(text: 'Top').scroll.to(:blah) }.to raise_error(ArgumentError)
      end
    end

    describe '#by' do
      it 'offset' do
        browser.scroll.to :bottom
        button = browser.button(text: 'Bottom')
        button.scroll.by(-10_000, -10_000) # simulate scrolling to top

        expect(visible?(browser.button(text: 'Top'))).to eq(true)
        expect(visible?(browser.button(text: 'Center'))).to eq(true)
        expect(visible?(browser.button(text: 'Bottom'))).to eq(false)
      end
    end
  end
end
