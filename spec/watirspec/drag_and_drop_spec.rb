require 'watirspec_helper'

describe 'Element' do
  context 'drag and drop', except: {browser: :ie} do
    before { browser.goto WatirSpec.url_for('drag_and_drop.html') }

    let(:draggable) { browser.div id: 'draggable' }
    let(:droppable) { browser.div id: 'droppable' }

    it 'can drag and drop an element onto another' do
      expect(droppable.text).to include 'Drop here'
      draggable.drag_and_drop_on droppable
      expect(droppable.text).to include 'Dropped!'
    end

    it 'can drag and drop an element onto another with specified scroll position' do
      expect(droppable.text).to include 'Drop here'
      draggable.drag_and_drop_on droppable, scroll_to: :center
      expect(droppable.text).to include 'Dropped!'
    end

    it 'can drag an element by the given offset' do
      expect(droppable.text).to include 'Drop here'
      draggable.drag_and_drop_by 200, 50
      expect(droppable.text).to include 'Dropped!'
    end

    it 'can drag an element by the given offset with specified scroll position' do
      expect(droppable.text).to include 'Drop here'
      draggable.drag_and_drop_by 200, 50, scroll_to: :center
      expect(droppable.text).to include 'Dropped!'
    end
  end
end
