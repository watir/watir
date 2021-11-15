require 'watirspec_helper'

describe 'Div' do
  before :each do
    browser.goto(WatirSpec.url_for('non_control_elements.html'))
  end

  describe '#exists?' do
    it 'returns true if the element exists' do
      expect(browser.div(id: 'header')).to exist
      expect(browser.div(id: /header/)).to exist
      expect(browser.div(title: 'Header and primary navigation')).to exist
      expect(browser.div(title: /Header and primary navigation/)).to exist
      expect(browser.div(text: 'Not shownNot hidden')).to exist
      expect(browser.div(text: /Not hidden/)).to exist
      expect(browser.div(class: 'profile')).to exist
      expect(browser.div(class: /profile/)).to exist
      expect(browser.div(index: 0)).to exist
      expect(browser.div(xpath: "//div[@id='header']")).to exist
      expect(browser.div(custom_attribute: 'custom')).to exist
      expect(browser.div(custom_attribute: /custom/)).to exist
      expect(browser.div(text: /some visible/)).to exist
      expect(browser.div(text: /some (visible|Jeff)/)).to exist
      expect(browser.div(text: /none visible/)).to exist
    end

    it 'returns the first div if given no args' do
      expect(browser.div).to exist
    end

    it 'returns false if the element does not exist' do
      expect(browser.div(id: 'no_such_id')).to_not exist
      expect(browser.div(id: /no_such_id/)).to_not exist
      expect(browser.div(title: 'no_such_title')).to_not exist
      expect(browser.div(title: /no_such_title/)).to_not exist
      expect(browser.div(text: 'no_such_text')).to_not exist
      expect(browser.div(text: /no_such_text/)).to_not exist
      expect(browser.div(class: 'no_such_class')).to_not exist
      expect(browser.div(class: /no_such_class/)).to_not exist
      expect(browser.div(text: /some visible some hidden/)).to exist
      expect(browser.div(index: 1337)).to_not exist
      expect(browser.div(xpath: "//div[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.div(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  # Attribute methods
  describe '#id' do
    it 'returns the id attribute if the element exists' do
      expect(browser.div(index: 1).id).to eq 'outer_container'
    end

    it "returns an empty string if the element exists, but the attribute doesn't" do
      expect(browser.div(index: 0).id).to eq ''
    end

    it 'raises UnknownObjectException if the element does not exist' do
      expect { browser.div(id: 'no_such_id').id }.to raise_unknown_object_exception
      expect { browser.div(title: 'no_such_id').id }.to raise_unknown_object_exception
      expect { browser.div(index: 1337).id }.to raise_unknown_object_exception
    end

    it 'should take all conditions into account when locating by id' do
      browser.goto WatirSpec.url_for 'multiple_ids.html'
      expect(browser.div(id: 'multiple', class: 'bar').class_name).to eq 'bar'
    end

    it 'should find the id with the correct tag name' do
      browser.goto WatirSpec.url_for 'multiple_ids.html'
      expect(browser.span(id: 'multiple').class_name).to eq 'foobar'
    end
  end

  describe '#style' do
    it 'returns the style attribute if the element exists' do
      expect(browser.div(id: 'best_language').style).to eq 'color: red; text-decoration: underline; cursor: pointer;'
    end

    it "returns an empty string if the element exists but the attribute doesn't" do
      expect(browser.div(id: 'promo').style).to eq ''
    end

    it 'raises UnknownObjectException if the element does not exist' do
      expect { browser.div(id: 'no_such_id').style }.to raise_unknown_object_exception
    end
  end

  describe '#text' do
    it 'returns the text of the div' do
      expect(browser.div(id: 'footer').text.strip).to eq 'This is a footer.'
      expect(browser.div(title: 'Closing remarks').text.strip).to eq 'This is a footer.'
      expect(browser.div(xpath: "//div[@id='footer']").text.strip).to eq 'This is a footer.'
    end

    it 'returns an empty string if the element exists but contains no text' do
      expect(browser.div(index: 0).text.strip).to eq ''
    end

    it 'returns an empty string if the div is hidden',
       except: {browser: :safari, reason: 'Safari is not filtering out hidden text'} do
      expect(browser.div(id: 'hidden').text).to eq ''
    end

    it 'raises UnknownObjectException if the element does not exist' do
      expect { browser.div(id: 'no_such_id').text }.to raise_unknown_object_exception
      expect { browser.div(title: 'no_such_title').text }.to raise_unknown_object_exception
      expect { browser.div(index: 1337).text }.to raise_unknown_object_exception
      expect { browser.div(xpath: "//div[@id='no_such_id']").text }.to raise_unknown_object_exception
    end
  end

  describe 'custom methods' do
    it 'returns the custom attribute if the element exists' do
      expect(browser.div(custom_attribute: 'custom').attribute_value('custom-attribute')).to eq 'custom'
    end
  end

  describe '#respond_to?' do
    it 'returns true for all attribute methods' do
      expect(browser.div(index: 0)).to respond_to(:class_name)
      expect(browser.div(index: 0)).to respond_to(:id)
      expect(browser.div(index: 0)).to respond_to(:style)
      expect(browser.div(index: 0)).to respond_to(:text)
    end
  end

  # Manipulation methods
  describe '#click' do
    it 'fires events when clicked' do
      expect(browser.div(id: 'best_language').text).to_not eq 'Ruby!'

      div = browser.div(id: 'best_language')
      div.scroll.to
      div.click
      expect(browser.div(id: 'best_language').text).to eq 'Ruby!'
    end

    it 'raises UnknownObjectException if the element does not exist' do
      expect { browser.div(id: 'no_such_id').click }.to raise_unknown_object_exception
      expect { browser.div(title: 'no_such_title').click }.to raise_unknown_object_exception
      expect { browser.div(index: 1337).click }.to raise_unknown_object_exception
      expect { browser.div(xpath: "//div[@id='no_such_id']").click }.to raise_unknown_object_exception
    end

    it 'includes custom message if element with a custom attribute does not exist' do
      message = /Watir treated \["custom_attribute"\] as a non-HTML compliant attribute, ensure that was intended/
      expect { browser.div(custom_attribute: 'not_there').click }.to raise_unknown_object_exception(message)
    end
  end

  describe '#click!' do
    it 'fires events when clicked' do
      expect(browser.div(id: 'best_language').text).to_not eq 'Ruby!'
      browser.div(id: 'best_language').click!
      expect(browser.div(id: 'best_language').text).to eq 'Ruby!'
    end

    it 'raises UnknownObjectException if the element does not exist' do
      expect { browser.div(id: 'no_such_id').click! }.to raise_unknown_object_exception
      expect { browser.div(title: 'no_such_title').click! }.to raise_unknown_object_exception
      expect { browser.div(index: 1337).click! }.to raise_unknown_object_exception
      expect { browser.div(xpath: "//div[@id='no_such_id']").click! }.to raise_unknown_object_exception
    end
  end

  describe '#double_click',
           except: {browser: :safari, reason: 'command correctly received, but action not taken'} do
    it 'fires the ondblclick event' do
      div = browser.div(id: 'html_test')
      div.double_click
      expect(messages).to include('double clicked')
    end

    it 'fires the ondblclick event with specified scroll position' do
      div = browser.div(id: 'html_test')
      div.double_click(scroll_to: :center)
      expect(messages).to include('double clicked')
    end
  end

  describe '#double_click!' do
    it 'fires the ondblclick event' do
      browser.div(id: 'html_test').double_click!
      expect(messages).to include('double clicked')
    end
  end

  describe '#right_click' do
    it 'fires the oncontextmenu event' do
      browser.goto(WatirSpec.url_for('right_click.html'))
      browser.div(id: 'click').right_click
      expect(messages.first).to eq 'right-clicked'
    end

    it 'accepts modifiers', except: {browser: :ie} do
      browser.goto(WatirSpec.url_for('right_click.html'))
      browser.div(id: 'click-logger').right_click(:control, :alt)
      expect(event_log.first).to eq('control=true alt=true')
    end

    it 'accepts modifiers with scroll position', except: {browser: :ie} do
      browser.goto(WatirSpec.url_for('right_click.html'))
      browser.div(id: 'click-logger').right_click(:control, :alt, scroll_to: :center)
      expect(event_log.first).to eq('control=true alt=true')
    end

    it 'scrolls' do
      browser.del(class: 'footer').double_click
      puts 'yes?'
    end
  end

  describe '#html' do
    it 'returns the HTML of the element' do
      html = browser.div(id: 'footer').html.downcase
      expect(html).to include('id="footer"')
      expect(html).to include('title="closing remarks"')
      expect(html).to include('class="profile"')

      expect(html).to_not include('<div id="content">')
      expect(html).to_not include('</body>')
    end
  end
end
