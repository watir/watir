require File.expand_path('watirspec/spec_helper', File.dirname(__FILE__))

describe Watir::Element do

  describe '#present?' do
    before do
      browser.goto(WatirSpec.url_for("wait.html", :needs_server => true))
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
  end

  describe "#reset!" do
    it "successfully relocates collection elements after a reset!" do
      element = browser.divs(:id, 'foo').to_a.first
      expect(element).to_not be_nil

      element.send :reset!
      expect(element).to exist
    end
  end

  describe "#exists?" do
    it "should not propagate ObsoleteElementErrors" do
      browser.goto WatirSpec.url_for('removed_element.html', :needs_server => true)

      button  = browser.button(:id => "remove-button")
      element = browser.div(:id => "text")

      expect(element).to exist
      button.click
      expect(element).to_not exist
    end
  end

  describe "#hover" do
    not_compliant_on [:webdriver, :firefox, :synthesized_events],
                     [:webdriver, :internet_explorer],
                     [:webdriver, :iphone],
                     [:webdriver, :safari] do
      it "should hover over the element" do
        browser.goto WatirSpec.url_for('hover.html', :needs_server => true)
        link = browser.a

        expect(link.style("font-size")).to eq "10px"
        link.hover
        expect(link.style("font-size")).to eq "20px"
      end
    end
  end

  describe "#next_sibling" do
    before :each do
      browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
    end

    it "gets the next sibling of this element" do
      sib = browser.text_field(:id, "new_user_email").next_sibling.next_sibling
      sib.should be_instance_of(Label)
      sib.text.should == 'Email address (confirmation)'
    end

    it "returns nil if the element has no next sibling" do
      browser.text_field(:id, "html5_email").next_sibling.should be_nil
    end
  end

  describe "#previous_sibling" do
    before :each do
      browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
    end

    it "gets the previous sibling of this element" do
      sib = browser.text_field(:id, "new_user_email").previous_sibling
      sib.should be_instance_of(Label)
      sib.text.should == 'Email address'
    end

    it "returns nil if the element has no previous sibling" do
      browser.legend(:text, "Personal information").previous_sibling.should be_nil
    end
  end

end
