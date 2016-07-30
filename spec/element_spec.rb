require File.expand_path('watirspec/spec_helper', File.dirname(__FILE__))

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

  describe "#reset!" do
    it "successfully relocates collection elements after a reset!" do
      browser.goto(WatirSpec.url_for("wait.html"))
      element = browser.div(id: 'foo')
      expect(element).to exist
      browser.refresh
      browser.div(id: 'foo').wait_until_present

      expect(element.exist?).to be false unless Watir.always_locate?
      element.send :reset!
      expect(element).to exist
    end
  end

  describe "#exists?" do
    before do
      browser.goto WatirSpec.url_for('removed_element.html')
    end

    it "returns false when an element from a collection becomes stale" do
      watir_element = browser.divs(id: "text").first
      expect(watir_element).to exist

      browser.refresh

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

      if Watir.always_locate?
        expect { watir_element.text }.to_not raise_error
      else
        expect { watir_element.text }.to raise_error Watir::Exception::UnknownObjectException
      end
    end

  end

  describe "#hover" do
    not_compliant_on :internet_explorer, :iphone, :safari do
      it "should hover over the element" do
        browser.goto WatirSpec.url_for('hover.html')
        link = browser.a

        expect(link.style("font-size")).to eq "10px"
        link.hover
        expect(link.style("font-size")).to eq "20px"
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
end
