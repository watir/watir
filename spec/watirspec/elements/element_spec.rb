require 'watirspec_helper'

describe 'Element' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  describe '.new' do
    it "finds elements matching the conditions when given a hash of :how => 'what' arguments" do
      expect(browser.checkbox(name: 'new_user_interests', title: 'Dancing is fun!').value).to eq 'dancing'
      expect(browser.text_field(class_name: 'name', index: 1).id).to eq 'new_user_last_name'
    end

    it "raises UnknownObjectException when given a hash of :how => 'what' arguments (non-existing object)" do
      expect { browser.text_field(index: 100, name: 'foo').id }.to raise_unknown_object_exception
    end

    it 'raises ArgumentError if given the wrong number of arguments' do
      container = double('container').as_null_object
      expect { Watir::Element.new(container, 1, 2, 3, 4) }.to raise_error(ArgumentError)
      expect { Watir::Element.new(container, 'foo') }.to raise_error(ArgumentError)
    end

    it 'throws deprecation warning when combining element locator with other locators' do
      element = double Selenium::WebDriver::Element
      allow(element).to receive(:enabled?).and_return(true)
      expect { browser.text_field(class_name: 'name', index: 1, element: element) }.to have_deprecated_element_cache
    end
  end

  describe '#element_call' do
    it 'handles exceptions when taking an action on a stale element' do
      browser.goto WatirSpec.url_for('removed_element.html')

      element = browser.div(id: 'text').locate

      browser.refresh

      expect(element).to be_stale
      expect { element.text }.to_not raise_error
    end

    compliant_on :relaxed_locate do
      it 'relocates stale element when taking an action on it' do
        browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
        element = browser.text_field(id: 'new_user_first_name').locate
        browser.refresh
        expect { element.click }.not_to raise_exception
      end
    end
  end

  describe '#eq and #eql?' do
    before { browser.goto WatirSpec.url_for('definition_lists.html') }

    it 'returns true if the two elements point to the same DOM element' do
      a = browser.dl(id: 'experience-list')
      b = browser.dl

      expect(a).to eq b
      expect(a).to eql(b)
    end

    it 'returns false if the two elements are not the same' do
      a = browser.dls[0]
      b = browser.dls[1]

      expect(a).to_not eq b
      expect(a).to_not eql(b)
    end

    it 'returns false if the other object is not an Element' do
      expect(browser.dl).to_not eq 1
    end
  end

  describe 'data-* attributes' do
    before { browser.goto WatirSpec.url_for('data_attributes.html') }

    it 'finds elements by a data-* attribute' do
      expect(browser.p(data_type: 'ruby-library')).to exist
    end

    it 'returns the value of a data-* attribute' do
      expect(browser.p.data_type).to eq 'ruby-library'
    end
  end

  describe 'aria-* attributes' do
    before { browser.goto WatirSpec.url_for('aria_attributes.html') }

    it 'finds elements by a aria-* attribute' do
      expect(browser.p(aria_label: 'ruby-library')).to exist
    end

    it 'returns the value of a aria-* attribute' do
      expect(browser.p.aria_label).to eq 'ruby-library'
    end
  end

  describe 'visible text' do
    it 'finds elements by visible text' do
      browser.goto WatirSpec.url_for('non_control_elements.html')

      expect(browser.element(visible_text: 'all visible')).to exist
      expect(browser.element(visible_text: /all visible/)).to exist
      expect(browser.element(visible_text: 'some visible')).to exist
      expect(browser.element(visible_text: /some visible/)).to exist
      expect(browser.element(visible_text: 'none visible')).not_to exist
      expect(browser.element(visible_text: /none visible/)).not_to exist

      expect(browser.element(visible_text: 'Link 2', class: 'external')).to exist
      expect(browser.element(visible_text: /Link 2/, class: 'external')).to exist
    end

    it 'raises exception unless value is a String or a RegExp' do
      browser.goto WatirSpec.url_for('non_control_elements.html')
      msg = /expected one of \[String, Regexp\], got 7\:(Fixnum|Integer)/
      expect { browser.element(visible_text: 7).exists? }.to raise_exception(TypeError, msg)
    end

    it 'raises exception unless key is valid' do
      browser.goto WatirSpec.url_for('non_control_elements.html')
      msg = /Unable to build XPath using 7:(Fixnum|Integer)/
      expect { browser.element(7 => /foo/).exists? }.to raise_exception(Watir::Exception::Error, msg)
    end
  end

  describe 'finding with unknown tag name' do
    it 'finds an element without arguments' do
      expect(browser.element).to exist
    end

    it 'finds an element by xpath' do
      expect(browser.element(xpath: "//*[@for='new_user_first_name']")).to exist
    end

    it 'finds an element by arbitrary attribute' do
      expect(browser.element(title: 'no title')).to exist
    end

    it 'finds several elements by xpath' do
      expect(browser.elements(xpath: '//a').length).to eq 1
    end

    it 'finds several elements by arbitrary attribute' do
      expect(browser.elements(id: /^new_user/).length).to eq 33
    end

    it "finds an element from an element's subtree" do
      expect(browser.fieldset.element(id: 'first_label')).to exist
      expect(browser.field_set.element(id: 'first_label')).to exist
    end

    it "finds several elements from an element's subtree" do
      expect(browser.fieldset.elements(xpath: './/label').length).to eq 23
    end
  end

  describe '#to_subtype' do
    it 'returns a CheckBox instance' do
      e = browser.input(xpath: "//input[@type='checkbox']").to_subtype
      expect(e).to be_kind_of(Watir::CheckBox)
    end

    it 'returns a Radio instance' do
      e = browser.input(xpath: "//input[@type='radio']").to_subtype
      expect(e).to be_kind_of(Watir::Radio)
    end

    it 'returns a Button instance' do
      es = [
        browser.input(xpath: "//input[@type='button']").to_subtype,
        browser.input(xpath: "//input[@type='submit']").to_subtype,
        browser.input(xpath: "//input[@type='reset']").to_subtype,
        browser.input(xpath: "//input[@type='image']").to_subtype
      ]

      es.all? { |e| expect(e).to be_kind_of(Watir::Button) }
    end

    it 'returns a TextField instance' do
      e = browser.input(xpath: "//input[@type='text']").to_subtype
      expect(e).to be_kind_of(Watir::TextField)
    end

    it 'returns a FileField instance' do
      e = browser.input(xpath: "//input[@type='file']").to_subtype
      expect(e).to be_kind_of(Watir::FileField)
    end

    it 'returns a Div instance' do
      el = browser.element(xpath: "//*[@id='messages']").to_subtype
      expect(el).to be_kind_of(Watir::Div)
    end
  end

  describe '#focus' do
    it 'fires the onfocus event for the given element' do
      tf = browser.text_field(id: 'new_user_occupation')
      expect(tf.value).to eq 'Developer'
      tf.focus
      expect(browser.div(id: 'onfocus_test').text).to eq 'changed by onfocus event'
    end
  end

  bug 'https://github.com/SeleniumHQ/selenium/issues/2555', %i[remote firefox] do
    bug 'https://github.com/SeleniumHQ/selenium/issues/1795', %i[remote edge] do
      describe '#focused?' do
        it 'knows if the element is focused' do
          expect(browser.element(id: 'new_user_first_name')).to be_focused
          expect(browser.element(id: 'new_user_last_name')).to_not be_focused
        end
      end
    end
  end

  describe '#fire_event' do
    it 'should fire the given event' do
      expect(browser.div(id: 'onfocus_test').text).to be_empty
      browser.text_field(id: 'new_user_occupation').fire_event('onfocus')
      expect(browser.div(id: 'onfocus_test').text).to eq 'changed by onfocus event'
    end
  end

  describe '#visible?' do
    it 'returns true if the element is visible' do
      msg = /WARN Watir \[\"visible_element\"\]/
      expect {
        expect(browser.text_field(id: 'new_user_email')).to be_visible
      }.to output(msg).to_stdout_from_any_process
    end

    it 'raises UnknownObjectException exception if the element does not exist' do
      msg = /WARN Watir \[\"visible_element\"\]/
      expect {
        expect { browser.text_field(id: 'no_such_id').visible? }.to raise_unknown_object_exception
      }.to output(msg).to_stdout_from_any_process
    end

    it 'raises UnknownObjectException exception if the element is stale' do
      element = browser.text_field(id: 'new_user_email').locate

      browser.refresh

      expect(element).to be_stale
      expect {
        expect { element.visible? }.to raise_unknown_object_exception
      }.to have_deprecated_stale_visible
    end

    it "returns true if the element has style='visibility: visible' even if parent has style='visibility: hidden'" do
      msg = /WARN Watir \[\"visible_element\"\]/
      expect {
        expect(browser.div(id: 'visible_child')).to be_visible
      }.to output(msg).to_stdout_from_any_process
    end

    it "returns false if the element is input element where type eq 'hidden'" do
      expect(browser.hidden(id: 'new_user_interests_dolls')).to_not be_visible
    end

    it "returns false if the element has style='display: none;'" do
      msg = /WARN Watir \[\"visible_element\"\]/
      expect {
        expect(browser.div(id: 'changed_language')).to_not be_visible
      }.to output(msg).to_stdout_from_any_process
    end

    it "returns false if the element has style='visibility: hidden;" do
      expect { expect(browser.div(id: 'wants_newsletter')).to_not be_visible }
    end

    it 'returns false if one of the parent elements is hidden' do
      expect { expect(browser.div(id: 'hidden_parent')).to_not be_visible }
    end
  end

  describe '#cache=' do
    it 'bypasses selector location' do
      browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))

      wd = browser.div.wd
      element = Watir::Element.new(browser, id: 'not_valid')
      element.cache = wd

      expect(element).to exist
    end

    it 'can be cleared' do
      browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))

      wd = browser.div.wd
      element = Watir::Element.new(browser, id: 'not_valid')
      element.cache = wd

      browser.refresh
      expect {
        expect(element).to_not exist
      }.to have_deprecated_stale_exists
    end
  end

  describe '#exists?' do
    before do
      browser.goto WatirSpec.url_for('removed_element.html')
    end

    it 'element from a collection returns false when it becomes stale' do
      element = browser.divs(id: 'text').first.locate

      browser.refresh

      expect(element).to be_stale
      expect {
        expect(element).to_not exist
      }.to have_deprecated_stale_exists
    end

    it 'returns false when tag name does not match id' do
      watir_element = browser.span(id: 'text')
      expect(watir_element).to_not exist
    end
  end

  describe '#present?' do
    before do
      browser.goto(WatirSpec.url_for('wait.html'))
    end

    it 'returns true if the element exists and is visible' do
      expect(browser.div(id: 'foo')).to be_present
    end

    it 'returns false if the element exists but is not visible' do
      expect(browser.div(id: 'bar')).to_not be_present
    end

    it 'returns false if the element does not exist' do
      expect(browser.div(id: 'should-not-exist')).to_not be_present
    end

    it 'returns false if the element is stale' do
      element = browser.div(id: 'foo').locate

      browser.refresh

      expect(element).to be_stale

      expect {
        expect(element).to_not be_present
      }.to have_deprecated_stale_present
    end

    it 'does not raise staleness deprecation if element no longer exists in DOM' do
      element = browser.div(id: 'foo').locate
      browser.goto(WatirSpec.url_for('iframes.html'))

      expect { element.present? }.to_not have_deprecated_stale_present
    end

    # TODO: Documents Current Behavior, but needs to be refactored/removed
    it 'returns true the second time if the element is stale' do
      element = browser.div(id: 'foo').locate

      browser.refresh

      expect(element).to be_stale

      expect {
        expect(element).to_not be_present
      }.to have_deprecated_stale_present
      expect(element).to be_present
    end
  end

  describe '#enabled?' do
    before do
      browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
    end

    it 'returns true if the element is enabled' do
      expect(browser.button(name: 'new_user_submit')).to be_enabled
    end

    it 'returns false if the element is disabled' do
      expect(browser.button(name: 'new_user_submit_disabled')).to_not be_enabled
    end

    it "raises UnknownObjectException if the element doesn't exist" do
      expect { browser.button(name: 'no_such_name').enabled? }.to raise_unknown_object_exception
    end
  end

  describe '#stale?' do
    it 'returns true if the element is stale' do
      element = browser.button(name: 'new_user_submit_disabled').locate

      browser.refresh

      expect(element).to be_stale
    end

    it 'returns false if the element is not stale' do
      element = browser.button(name: 'new_user_submit_disabled').locate

      expect(element).to_not be_stale
    end
  end

  describe '#exist?' do
    context ':class locator' do
      before do
        browser.goto(WatirSpec.url_for('class_locator.html'))
      end

      it 'matches when the element has a single class' do
        e = browser.div(class: 'a')
        expect(e).to exist
        expect(e.class_name).to eq 'a'
      end

      it 'matches when the element has several classes' do
        e = browser.div(class: 'b')
        expect(e).to exist
        expect(e.class_name).to eq 'a b c'
      end

      it 'does not match only part of the class name' do
        expect(browser.div(class: 'bc')).to_not exist
      end

      it 'matches part of the class name when given a regexp' do
        expect(browser.div(class: /c/)).to exist
      end

      context 'with multiple classes' do
        it 'matches when the element has a single class' do
          e = browser.div(class: ['a'])
          expect(e).to exist
          expect(e.class_name).to eq 'a'
        end

        it 'matches a non-ordered subset' do
          e = browser.div(class: %w[c a])
          expect(e).to exist
          expect(e.class_name).to eq 'a b c'
        end

        it 'matches one with a negation' do
          e = browser.div(class: ['!a'])
          expect(e).to exist
          expect(e.class_name).to eq 'abc'
        end

        it 'matches multiple with a negation' do
          e = browser.div(class: ['a', '!c', 'b'])
          expect(e).to exist
          expect(e.class_name).to eq 'a b'
        end
      end
    end

    context 'attribute presence' do
      before { browser.goto WatirSpec.url_for('data_attributes.html') }

      it 'finds element by attribute presence' do
        expect(browser.p(data_type: true)).to exist
        expect(browser.p(class: true)).not_to exist
      end

      it 'finds element by attribute absence' do
        expect(browser.p(data_type: false)).not_to exist
        expect(browser.p(class: false)).to exist
      end
    end

    context ':index locator' do
      before { browser.goto WatirSpec.url_for('data_attributes.html') }

      it 'finds the first element by index: 0' do
        expect(browser.element(index: 0).tag_name).to eq 'html'
      end

      it 'finds the second element by index: 1' do
        expect(browser.element(index: 1).tag_name).to eq 'head'
      end

      it 'finds the last element by index: -1' do
        expect(browser.element(index: -1).tag_name).to eq 'div'
      end
    end

    it "doesn't raise when called on nested elements" do
      expect(browser.div(id: 'no_such_div').link(id: 'no_such_id')).to_not exist
    end

    it "doesn't raise when selector has with :xpath has :index" do
      expect(browser.div(xpath: '//div', index: 1)).to exist
    end

    it "doesn't raise when selector has with :css has :index" do
      expect(browser.div(css: 'div', index: 1)).to exist
    end

    it 'finds element by Selenium name locator' do
      expect(browser.element(name: 'new_user_first_name')).to exist
      expect(browser.element(name: /new_user_first_name/)).to exist
    end

    it 'returns false when tag name does not match id' do
      watir_element = browser.span(id: 'text')
      expect(watir_element).to_not exist
    end
  end

  describe '#send_keys' do
    before(:each) do
      @c = Selenium::WebDriver::Platform.mac? ? :command : :control
      browser.goto(WatirSpec.url_for('keylogger.html'))
    end

    let(:receiver) { browser.text_field(id: 'receiver') }
    let(:events) { browser.element(id: 'output').ps.size }

    it 'sends keystrokes to the element' do
      receiver.send_keys 'hello world'
      expect(receiver.value).to eq 'hello world'
      expect(events).to eq 11
    end

    it 'accepts arbitrary list of arguments' do
      receiver.send_keys 'hello', 'world'
      expect(receiver.value).to eq 'helloworld'
      expect(events).to eq 10
    end

    bug 'http://code.google.com/p/chromium/issues/detail?id=93879', :chrome do
      not_compliant_on :safari, :firefox do
        it 'performs key combinations' do
          receiver.send_keys 'foo'
          receiver.send_keys [@c, 'a']
          receiver.send_keys :backspace
          expect(receiver.value).to be_empty
          expect(events).to eq 6
        end

        it 'performs arbitrary list of key combinations' do
          receiver.send_keys 'foo'
          receiver.send_keys [@c, 'a'], [@c, 'x']
          expect(receiver.value).to be_empty
          expect(events).to eq 7
        end

        it 'supports combination of strings and arrays' do
          receiver.send_keys 'foo', [@c, 'a'], :backspace
          expect(receiver.value).to be_empty
          expect(events).to eq 6
        end
      end
    end
  end

  describe '#click' do
    bug 'https://github.com/mozilla/geckodriver/issues/1375', :firefox do
      it 'accepts modifiers' do
        begin
          browser.a.click(:shift)
          expect(browser.windows.size).to eq 2
        ensure
          browser.windows.reject(&:current?).each(&:close)
          expect(browser.windows.size).to eq 1
        end
      end
    end
  end

  describe '#flash' do
    let(:h2) { browser.h2(text: 'Add user') }
    let(:h1) { browser.h1(text: 'User administration') }

    it 'returns the element on which it was called' do
      expect(h2.flash).to eq h2
    end

    it 'should keep the element background color after flashing' do
      expect(h2.style('background-color')).to eq h2.flash(:rainbow).style('background-color')
      expect(h1.style('background-color')).to eq h1.flash.style('background-color')
    end

    it 'should respond to preset symbols like :fast and :slow' do
      expect(h1.flash(:rainbow)).to eq h1
      expect(h2.flash(:slow)).to eq h2
      expect(h1.flash(:fast)).to eq h1
      expect(h2.flash(:long)).to eq h2
    end
  end

  describe '#hover' do
    not_compliant_on :internet_explorer, :safari do
      it 'should hover over the element' do
        browser.goto WatirSpec.url_for('hover.html')
        link = browser.a

        expect(link.style('font-size')).to eq '10px'
        link.hover
        link.wait_until { |l| l.style('font-size') == '20px' }
        expect(link.style('font-size')).to eq '20px'
      end
    end
  end

  describe '#inspect' do
    before(:each) { browser.goto(WatirSpec.url_for('nested_iframes.html')) }

    it 'does displays specified element type' do
      expect(browser.div.inspect).to include('Watir::Div')
    end

    it 'does not display element type if not specified' do
      element = browser.element(index: 4)
      expect(element.inspect).to include('Watir::HTMLElement')
    end

    it 'displays keyword if specified' do
      element = browser.h3
      element.keyword = 'foo'
      expect(element.inspect).to include('keyword: foo')
    end

    it 'does not display keyword if not specified' do
      element = browser.h3
      expect(element.inspect).to_not include('keyword')
    end

    it 'locate is false when not located' do
      element = browser.div(id: 'not_present')
      expect(element.inspect).to include('located: false')
    end

    it 'locate is true when located' do
      element = browser.h3
      element.exists?
      expect(element.inspect).to include('located: true')
    end

    it 'displays selector string for element from colection' do
      elements = browser.frames
      expect(elements.last.inspect).to include '{:tag_name=>"frame", :index=>-1}'
    end

    it 'displays selector string for nested element' do
      browser.goto(WatirSpec.url_for('wait.html'))
      element = browser.div(index: 1).div(id: 'div2')
      expect(element.inspect).to include '{:index=>1, :tag_name=>"div"} --> {:id=>"div2", :tag_name=>"div"}'
    end

    it 'displays selector string for nested element under frame' do
      element = browser.iframe(id: 'one').iframe(id: 'three')
      expect(element.inspect).to include '{:id=>"one", :tag_name=>"iframe"} --> {:id=>"three", :tag_name=>"iframe"}'
    end
  end

  describe '#text_content' do
    it 'returns inner Text code of element' do
      browser.goto WatirSpec.url_for('non_control_elements.html')
      expect(browser.div(id: 'shown').text_content).to eq('Not shownNot hidden')
    end
  end

  describe '#inner_text' do
    it 'returns inner HTML code of element' do
      browser.goto WatirSpec.url_for('non_control_elements.html')
      div = browser.div(id: 'shown')
      expect(div.inner_text).to eq('Not hidden')
    end
  end

  describe '#inner_html' do
    it 'returns inner HTML code of element' do
      browser.goto WatirSpec.url_for('non_control_elements.html')
      div = browser.div(id: 'shown')
      expected_text = '<div id="hidden" style="display: none;">Not shown</div><div>Not hidden</div>'
      expect(div.inner_html).to eq expected_text
    end
  end

  describe '#outer_html' do
    it 'returns outer (inner + element itself) HTML code of element' do
      browser.goto WatirSpec.url_for('non_control_elements.html')
      div = browser.div(id: 'shown')
      text = '<div id="shown"><div id="hidden" style="display: none;">Not shown</div><div>Not hidden</div></div>'
      expect(div.outer_html).to eq text
    end
  end

  describe '#select_text and #selected_text' do
    it 'selects text and returns selected text' do
      browser.goto WatirSpec.url_for('non_control_elements.html')
      element = browser.element(visible_text: 'all visible')
      element.select_text('all visible')
      expect(element.selected_text).to eq 'all visible'
    end
  end

  not_compliant_on %i[remote firefox] do
    describe '#scroll_into_view' do
      it 'scrolls element into view' do
        el = browser.button(name: 'new_user_image')
        element_center = el.center['y']

        bottom_viewport_script = 'return window.pageYOffset + window.innerHeight'
        expect(browser.execute_script(bottom_viewport_script)).to be < element_center

        expect(el.scroll_into_view).to be_a Selenium::WebDriver::Point

        expect(browser.execute_script(bottom_viewport_script)).to be > element_center
      end
    end
  end

  describe '#location' do
    it 'returns coordinates for element location' do
      location = browser.button(name: 'new_user_image').location

      expect(location).to be_a Selenium::WebDriver::Point
      expect(location['y']).to be > 0
      expect(location['x']).to be > 0
    end
  end

  describe '#size' do
    it 'returns size of element' do
      size = browser.button(name: 'new_user_image').size

      expect(size).to be_a Selenium::WebDriver::Dimension
      expect(size['width']).to eq 104.0
      expect(size['height']).to eq 70.0
    end
  end

  describe '#height' do
    it 'returns height of element' do
      height = browser.button(name: 'new_user_image').height

      expect(height).to eq 70.0
    end
  end

  describe '#width' do
    it 'returns width of element' do
      width = browser.button(name: 'new_user_image').width

      expect(width).to eq 104.0
    end
  end

  describe '#center' do
    it 'returns center of element' do
      center = browser.button(name: 'new_user_image').center

      expect(center).to be_a Selenium::WebDriver::Point
      expect(center['y']).to be > 0.0
      expect(center['x']).to be > 0.0
    end
  end

  describe '#attribute_value' do
    before { browser.goto WatirSpec.url_for('data_attributes.html') }

    it 'returns attribute value by string attribute name' do
      expect(browser.p.attribute_value('data-type')).to eq 'ruby-library'
    end

    it 'returns attribute value by symbol attribute name' do
      expect(browser.p.attribute_value(:data_type)).to eq 'ruby-library'
    end
  end

  describe '#attribute_values' do
    before { browser.goto WatirSpec.url_for('data_attributes.html') }

    it 'returns a Hash object' do
      expect(browser.p.attribute_values).to be_an_instance_of(Hash)
    end

    it 'returns attribute values from an element' do
      expected = {data_type: 'ruby-library'}
      expect(browser.p.attribute_values).to eq expected
    end

    it 'returns attribute with special characters' do
      expected = {data_type: 'description', 'data-type_$p3c!a1' => 'special-description'}
      expect(browser.div.attribute_values).to eq expected
    end

    it 'returns attribute with special characters as a String' do
      expect(browser.div.attribute_values.keys[0]).to be_an_instance_of(String)
    end
  end

  describe '#attribute_list' do
    before { browser.goto WatirSpec.url_for('data_attributes.html') }

    it 'returns an Array object' do
      expect(browser.div.attribute_list).to be_an_instance_of(Array)
    end

    it 'returns list of attributes from an element' do
      expect(browser.p.attribute_list).to eq [:data_type]
    end

    it 'returns attribute name with special characters as a String' do
      expect(browser.div.attribute_list[0]).to be_an_instance_of(String)
    end
  end

  describe '#located?' do
    it 'returns true if element has been located' do
      expect(browser.form(id: 'new_user')).to_not be_located
    end

    it 'returns false if element has not been located' do
      expect(browser.form(id: 'new_user').locate).to be_located
    end
  end

  describe '#wd' do
    it 'returns a Selenium::WebDriver::Element instance' do
      element = browser.text_field(id: 'new_user_email')
      expect(element.wd).to be_a(Selenium::WebDriver::Element)
    end
  end

  describe '#hash' do
    it 'returns a hash' do
      element = browser.text_field(id: 'new_user_email')
      hash1 = element.hash
      hash2 = element.locate.hash
      expect(hash1).to be_a Integer
      expect(hash2).to be_a Integer
      expect(hash1).to_not eq hash2
    end
  end

  describe 'Float Attribute' do
    it 'returns Float value of applicable element' do
      element = browser.text_field(id: 'number')
      expect(element.valueasnumber).to be_a Float
    end

    it 'returns nil value for an inapplicable Element' do
      element = browser.input
      expect(element.valueasnumber).to be_nil
    end
  end

  describe 'Integer Attribute' do
    it 'returns Float value of applicable element' do
      element = browser.form
      expect(element.length).to be_a Integer
    end

    it 'returns -1 for an inapplicable Element' do
      element = browser.input
      expect(element.maxlength).to eq(-1)
    end
  end

  describe '#class_name' do
    it 'returns single class name' do
      expect(browser.form(id: 'new_user').class_name).to eq 'user'
    end

    it 'returns multiple class names in a String' do
      expect(browser.div(id: 'messages').class_name).to eq 'multiple classes here'
    end

    it 'returns an empty string if the element exists but there is no class attribute' do
      expect(browser.div(id: 'changed_language').class_name).to eq ''
    end

    it 'raises UnknownObjectException if the element does not exist' do
      expect { browser.div(id: 'no_such_id').class_name }.to raise_unknown_object_exception
    end
  end

  describe '#classes' do
    it 'returns the class attribute if the element exists' do
      expect(browser.div(id: 'messages').classes).to eq %w[multiple classes here]
    end

    it 'returns an empty array if the element exists but there is no class attribute' do
      expect(browser.div(id: 'changed_language').classes).to eq []
    end

    it 'raises UnknownObjectException if the element does not exist' do
      expect { browser.div(id: 'no_such_id').classes }.to raise_unknown_object_exception
    end
  end

  describe '#obscured?' do
    before { browser.goto WatirSpec.url_for('obscured.html') }

    it 'returns false if element\'s center is not covered' do
      btn = browser.button(id: 'not_obscured')
      expect(btn).not_to be_obscured
      expect { btn.click }.not_to raise_exception
    end

    it 'returns false if element\'s center is covered by its descendant' do
      btn = browser.button(id: 'has_descendant')
      expect(btn).not_to be_obscured
      expect { btn.click }.not_to raise_exception
    end

    it 'returns true if element\'s center is covered by a non-descendant' do
      btn = browser.button(id: 'obscured')
      expect(btn).to be_obscured
      not_compliant_on :chrome do
        expect { btn.click }.to raise_exception(Selenium::WebDriver::Error::ElementClickInterceptedError)
      end
      compliant_on :chrome do
        expect { btn.click }.to raise_exception(Selenium::WebDriver::Error::UnknownError)
      end
    end

    not_compliant_on %i[firefox appveyor] do
      it 'returns false if element\'s center is surrounded by non-descendants' do
        btn = browser.button(id: 'surrounded')
        expect(btn).not_to be_obscured
        expect { btn.click }.not_to raise_exception
      end
    end

    it 'scrolls interactive element into view before checking if obscured' do
      btn = browser.button(id: 'requires_scrolling')
      expect(btn).not_to be_obscured
      expect { btn.click }.not_to raise_exception
    end

    it 'scrolls non-interactive element into view before checking if obscured' do
      div = browser.div(id: 'requires_scrolling_container')
      expect(div).not_to be_obscured
      expect { div.click }.not_to raise_exception
    end

    it 'returns true if element cannot be scrolled into view' do
      btn = browser.button(id: 'off_screen')
      expect(btn).to be_obscured
      expect { btn.click }.to raise_unknown_object_exception
    end

    it 'returns true if element is hidden' do
      btn = browser.button(id: 'hidden')
      expect(btn).to be_obscured
      expect { btn.click }.to raise_unknown_object_exception
    end

    it 'raises UnknownObjectException if element does not exist' do
      expect { browser.button(id: 'does_not_exist').obscured? }.to raise_unknown_object_exception
    end
  end
end
