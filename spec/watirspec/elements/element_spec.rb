require "watirspec_helper"

describe "Element" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  describe ".new" do
    it "finds elements matching the conditions when given a hash of :how => 'what' arguments" do
      expect(browser.checkbox(name: 'new_user_interests', title: 'Dancing is fun!').value).to eq 'dancing'
      expect(browser.text_field(class_name: 'name', index: 1).id).to eq 'new_user_last_name'
    end

    it "raises UnknownObjectException with a sane error message when given a hash of :how => 'what' arguments (non-existing object)" do
      expect { browser.text_field(index: 100, name: "foo").id }.to raise_unknown_object_exception
    end

    it "raises ArgumentError if given the wrong number of arguments" do
      container = double("container").as_null_object
      expect { Watir::Element.new(container, 1, 2, 3, 4) }.to raise_error(ArgumentError)
      expect { Watir::Element.new(container, "foo") }.to raise_error(ArgumentError)
    end
  end

  describe "#eq and #eql?" do
    before { browser.goto WatirSpec.url_for("definition_lists.html") }

    it "returns true if the two elements point to the same DOM element" do
      a = browser.dl(id: "experience-list")
      b = browser.dl

      expect(a).to eq b
      expect(a).to eql(b)
    end

    it "returns false if the two elements are not the same" do
      a = browser.dls[0]
      b = browser.dls[1]

      expect(a).to_not eq b
      expect(a).to_not eql(b)
    end

    it "returns false if the other object is not an Element" do
      expect(browser.dl).to_not eq 1
    end
  end

  describe "data-* attributes" do
    before { browser.goto WatirSpec.url_for("data_attributes.html") }

    it "finds elements by a data-* attribute" do
      expect(browser.p(data_type: "ruby-library")).to exist
    end

    it "returns the value of a data-* attribute" do
      expect(browser.p.data_type).to eq "ruby-library"
    end
  end

  describe "aria-* attributes" do
    before { browser.goto WatirSpec.url_for("aria_attributes.html") }

    it "finds elements by a aria-* attribute" do
      expect(browser.p(aria_label: "ruby-library")).to exist
    end

    it "returns the value of a aria-* attribute" do
      expect(browser.p.aria_label).to eq "ruby-library"
    end
  end

  describe "visible text" do
    it "finds elements by visible text" do
      browser.goto WatirSpec.url_for('non_control_elements.html')

      expect(browser.link(visible_text: "all visible")).to exist
      expect(browser.link(visible_text: /all visible/)).to exist
      expect(browser.link(visible_text: "some visible")).to exist
      expect(browser.link(visible_text: /some visible/)).to exist
      expect(browser.link(visible_text: "none visible")).not_to exist
      expect(browser.link(visible_text: /none visible/)).not_to exist

      expect(browser.link(visible_text: "Link 2", class: "external")).to exist
      expect(browser.link(visible_text: /Link 2/, class: "external")).to exist

      expect(browser.element(visible_text: "all visible")).to exist
      expect(browser.element(visible_text: /all visible/)).to exist
      expect(browser.element(visible_text: "some visible")).to exist
      expect(browser.element(visible_text: /some visible/)).to exist
    end
  end

  describe "finding with unknown tag name" do
    it "finds an element without arguments" do
      expect(browser.element).to exist
    end

    it "finds an element by xpath" do
      expect(browser.element(xpath: "//*[@for='new_user_first_name']")).to exist
    end

    it "finds an element by arbitrary attribute" do
      expect(browser.element(title: "no title")).to exist
    end

    it "finds several elements by xpath" do
      expect(browser.elements(xpath: "//a").length).to eq 1
    end

    it "finds several elements by arbitrary attribute" do
      expect(browser.elements(id: /^new_user/).length).to eq 33
    end

    it "finds an element from an element's subtree" do
      expect(browser.fieldset.element(id: "first_label")).to exist
      expect(browser.field_set.element(id: "first_label")).to exist
    end

    it "finds several elements from an element's subtree" do
      expect(browser.fieldset.elements(xpath: ".//label").length).to eq 21
    end
  end

  describe "#to_subtype" do
    it "returns a CheckBox instance" do
      e = browser.input(xpath: "//input[@type='checkbox']").to_subtype
      expect(e).to be_kind_of(Watir::CheckBox)
    end

    it "returns a Radio instance" do
      e = browser.input(xpath: "//input[@type='radio']").to_subtype
      expect(e).to be_kind_of(Watir::Radio)
    end

    it "returns a Button instance" do
      es = [
        browser.input(xpath: "//input[@type='button']").to_subtype,
        browser.input(xpath: "//input[@type='submit']").to_subtype,
        browser.input(xpath: "//input[@type='reset']").to_subtype,
        browser.input(xpath: "//input[@type='image']").to_subtype
      ]

      es.all? { |e| expect(e).to be_kind_of(Watir::Button) }
    end

    it "returns a TextField instance" do
      e = browser.input(xpath: "//input[@type='text']").to_subtype
      expect(e).to be_kind_of(Watir::TextField)
    end

    it "returns a FileField instance" do
      e = browser.input(xpath: "//input[@type='file']").to_subtype
      expect(e).to be_kind_of(Watir::FileField)
    end

    it "returns a Div instance" do
      el = browser.element(xpath: "//*[@id='messages']").to_subtype
      expect(el).to be_kind_of(Watir::Div)
    end
  end

  describe "#focus" do
    it "fires the onfocus event for the given element" do
      tf = browser.text_field(id: "new_user_occupation")
      expect(tf.value).to eq "Developer"
      tf.focus
      expect(browser.div(id: "onfocus_test").text).to eq "changed by onfocus event"
    end
  end

  bug "https://github.com/SeleniumHQ/selenium/issues/2555", %i(remote firefox) do
    bug "https://github.com/SeleniumHQ/selenium/issues/1795", %i(remote edge) do
      describe "#focused?" do
        it "knows if the element is focused" do
          expect(browser.element(id: 'new_user_first_name')).to be_focused
          expect(browser.element(id: 'new_user_last_name')).to_not be_focused
        end
      end
    end
  end

  describe "#fire_event" do
    it "should fire the given event" do
      expect(browser.div(id: "onfocus_test").text).to be_empty
      browser.text_field(id: "new_user_occupation").fire_event('onfocus')
      expect(browser.div(id: "onfocus_test").text).to eq "changed by onfocus event"
    end
  end

  describe "#visible?" do
    it "returns true if the element is visible" do
      expect(browser.text_field(id: "new_user_email")).to be_visible
    end

    it "raises UnknownObjectException exception if the element does not exist" do
      expect { browser.text_field(id: "no_such_id").visible? }.to raise_unknown_object_exception
    end

    it "raises UnknownObjectException exception if the element is stale" do
      wd_element = browser.text_field(id: "new_user_email").wd

      # simulate element going stale during lookup
      allow(browser.driver).to receive(:find_element).with(:css, '#new_user_email') { wd_element }
      allow(browser.driver).to receive(:find_elements).with(:css, '#new_user_email') { [wd_element] }
      allow(browser.driver).to receive(:find_elements).with(:tag_name, 'iframe') { [] }
      browser.refresh

      expect { browser.text_field(css: '#new_user_email').visible? }.to raise_unknown_object_exception
    end

    it "returns true if the element has style='visibility: visible' even if parent has style='visibility: hidden'" do
      expect(browser.div(id: "visible_child")).to be_visible
    end

    it "returns false if the element is input element where type eq 'hidden'" do
      expect(browser.hidden(id: "new_user_interests_dolls")).to_not be_visible
    end

    it "returns false if the element has style='display: none;'" do
      expect(browser.div(id: 'changed_language')).to_not be_visible
    end

    it "returns false if the element has style='visibility: hidden;" do
      expect(browser.div(id: 'wants_newsletter')).to_not be_visible
    end

    it "returns false if one of the parent elements is hidden" do
      expect(browser.div(id: 'hidden_parent')).to_not be_visible
    end
  end

  describe "#exist?" do
    context ":class locator" do
      before do
        browser.goto(WatirSpec.url_for("class_locator.html"))
      end

      it "matches when the element has a single class" do
        e = browser.div(class: "a")
        expect(e).to exist
        expect(e.class_name).to eq "a"
      end

      it "matches when the element has several classes" do
        e = browser.div(class: "b")
        expect(e).to exist
        expect(e.class_name).to eq "a b c"
      end

      it "does not match only part of the class name" do
        expect(browser.div(class: "bc")).to_not exist
      end

      it "matches part of the class name when given a regexp" do
        expect(browser.div(class: /c/)).to exist
      end

      context "with multiple classes" do
        it "matches when the element has a single class" do
          e = browser.div(class: ["a"])
          expect(e).to exist
          expect(e.class_name).to eq "a"
        end

        it "matches a non-ordered subset" do
          e = browser.div(class: ["c", "a"])
          expect(e).to exist
          expect(e.class_name).to eq "a b c"
        end

        it "matches one with a negation" do
          e = browser.div(class: ["!a"])
          expect(e).to exist
          expect(e.class_name).to eq "abc"
        end

        it "matches multiple with a negation" do
          e = browser.div(class: ["a", "!c", "b"])
          expect(e).to exist
          expect(e.class_name).to eq "a b"
        end
      end
    end

    context "attribute presence" do
      before { browser.goto WatirSpec.url_for("data_attributes.html") }

      it "finds element by attribute presence" do
        expect(browser.p(data_type: true)).to exist
        expect(browser.p(class: true)).not_to exist
      end

      it "finds element by attribute absence" do
        expect(browser.p(data_type: false)).not_to exist
        expect(browser.p(class: false)).to exist
      end
    end

    it "doesn't raise when called on nested elements" do
      expect(browser.div(id: 'no_such_div').link(id: 'no_such_id')).to_not exist
    end

    it "raises if both :xpath and :css are given" do
      expect { browser.div(xpath: "//div", css: "div").exists? }.to raise_error(ArgumentError)
    end

    it "doesn't raise when selector has with :xpath has :index" do
      expect(browser.div(xpath: "//div", index: 1)).to exist
    end

    it "raises ArgumentError error if selector hash with :xpath has multiple entries" do
      expect { browser.div(xpath: "//div", class: "foo").exists? }.to raise_error(ArgumentError)
    end

    it "doesn't raise when selector has with :css has :index" do
      expect(browser.div(css: "div", index: 1)).to exist
    end

    it "raises ArgumentError error if selector hash with :css has multiple entries" do
      expect { browser.div(css: "div", class: "foo").exists? }.to raise_error(ArgumentError)
    end

    it "finds element by Selenium name locator" do
      expect(browser.element(name: "new_user_first_name")).to exist
      expect(browser.element(name: /new_user_first_name/)).to exist
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

    bug "http://code.google.com/p/chromium/issues/detail?id=93879", :chrome do
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

  describe "#flash" do

    let(:h2) { browser.h2(text: 'Add user') }

    it 'returns the element on which it was called' do
      expect(h2.flash).to eq h2
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
      expected_text = "<div id=\"hidden\" style=\"display: none;\">Not shown</div><div>Not hidden</div>"
      expect(div.inner_html).to eq expected_text
    end
  end

  describe '#outer_html' do
    it 'returns outer (inner + element itself) HTML code of element' do
      browser.goto WatirSpec.url_for('non_control_elements.html')
      div = browser.div(id: 'shown')
      expected_text = "<div id=\"shown\"><div id=\"hidden\" style=\"display: none;\">Not shown</div><div>Not hidden</div></div>"
      expect(div.outer_html).to eq expected_text
    end
  end

  not_compliant_on %i(remote firefox) do
    describe '#scroll_into_view' do
      it 'scrolls element into view' do
        el = browser.button(name: 'new_user_image')
        element_center = el.center['y']

        bottom_viewport_script = 'return window.pageYOffset + window.innerHeight'
        expect(browser.execute_script bottom_viewport_script).to be < element_center

        expect(el.scroll_into_view).to be_a Selenium::WebDriver::Point

        expect(browser.execute_script bottom_viewport_script).to be > element_center
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

end
