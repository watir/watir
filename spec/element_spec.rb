require 'watirspec_helper'

describe Watir::Element do

  describe '#present?' do
    before do
      browser.goto(WatirSpec.url_for("wait.html"))
    end

    it 'returns true if the element exists and is visible' do
      expect(browser.div(:id, 'foo')).to be_present
    end

    it 'returns false if the element exists but is not visible' do
      expect(browser.div(:id, 'bar')).to_not be_present
    end

    it 'returns false if the element does not exist' do
      expect(browser.div(:id, 'should-not-exist')).to_not be_present
    end

    it "returns false if the element is stale" do
      wd_element = browser.div(id: "foo").wd

      # simulate element going stale during lookup
      allow(browser.driver).to receive(:find_element).with(:id, 'foo') { wd_element }
      browser.refresh

      expect(browser.div(:id, 'foo')).to_not be_present
    end

  end

  describe "#enabled?" do
    before do
      browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
    end

    it "returns true if the element is enabled" do
      expect(browser.element(name: 'new_user_submit')).to be_enabled
    end

    it "returns false if the element is disabled" do
      expect(browser.element(name: 'new_user_submit_disabled')).to_not be_enabled
    end

    it "raises UnknownObjectException if the element doesn't exist" do
      expect { browser.element(name: "no_such_name").enabled? }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#exists?" do
    before do
      browser.goto WatirSpec.url_for('removed_element.html')
    end

    it "relocates element from a collection when it becomes stale" do
      watir_element = browser.divs(id: "text").first
      expect(watir_element).to exist

      browser.refresh

      expect(watir_element).to exist
    end

    it "returns false when tag name does not match id" do
      watir_element = browser.span(id: "text")
      expect(watir_element).to_not exist
    end
  end

  describe "#element_call" do

    it 'handles exceptions when taking an action on an element that goes stale during execution' do
      browser.goto WatirSpec.url_for('removed_element.html')

      watir_element = browser.div(id: "text")

        # simulate element going stale after assert_exists and before action taken
      allow(watir_element).to receive(:text) do
        watir_element.send :assert_exists
        browser.refresh
        watir_element.send(:element_call) { watir_element.instance_variable_get('@element').text }
      end

      expect { watir_element.text }.to_not raise_error
    end

  end

  bug "Actions Endpoint Not Yet Implemented", :firefox do
    describe "#hover" do
      not_compliant_on :internet_explorer, :safari do
        it "should hover over the element" do
          browser.goto WatirSpec.url_for('hover.html')
          link = browser.a

          expect(link.style("font-size")).to eq "10px"
          link.hover
          expect(link.style("font-size")).to eq "20px"
        end
      end
    end
  end

  # TODO - Can remove when decide issue #295
  describe "warnings" do
    it "does not return a warning if using text_field for an unspecified text input" do
       browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
      expect do
       browser.text_field(id: "new_user_first_name").exists?
      end.to_not output.to_stderr
    end

    it "returns a warning if using text_field for textarea" do
      browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
      expect do
        browser.text_field(id: "create_user_comment").exists?
      end.to output.to_stderr
    end
  end

  describe "#selector_string" do
    it "displays selector string for regular element" do
      browser.goto(WatirSpec.url_for("wait.html"))
      delegator = browser.div(:id, 'foo').when_present
      message = delegator.instance_variable_get('@message')
      expect(message).to eq 'waiting for {:id=>"foo", :tag_name=>"div"} to become present'
    end

    it "displays selector string for element from colection" do
      browser.goto(WatirSpec.url_for("wait.html"))
      delegator = browser.divs.last.when_present
      message = delegator.instance_variable_get('@message')
      expect(message).to match /waiting for {:tag_name=>\"div\", :index=>3} to become present/
    end

    it "displays selector string for nested element" do
      browser.goto(WatirSpec.url_for("wait.html"))
      delegator = browser.div(index: -1).div(:id, 'foo').when_present
      message = delegator.instance_variable_get('@message')
      expect(message).to eq 'waiting for {:index=>-1, :tag_name=>"div"} --> {:id=>"foo", :tag_name=>"div"} to become present'
    end

    it "displays selector string for nested element under frame" do
      browser.goto(WatirSpec.url_for("nested_iframes.html"))
      delegator = browser.iframe(id: 'one').iframe(:id, 'three').when_present
      message = delegator.instance_variable_get('@message')
      expect(message).to eq 'waiting for {:id=>"one", :tag_name=>"iframe"} --> {:id=>"three", :tag_name=>"iframe"} to become present'
    end
  end
end
