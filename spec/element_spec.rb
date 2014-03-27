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

  describe '#inner_html' do
    it 'should return inner HTML code of element' do
      browser.goto WatirSpec.url_for('inner_outer.html', :needs_server => true)
      div = browser.div(:id => 'foo')
      expect(div.inner_html).to eq('<a href="#">hello</a>')
    end
  end

  describe '#outer_html' do
    it 'Returns outer (inner + element itself) HTML code of element' do
      browser.goto WatirSpec.url_for('inner_outer.html', :needs_server => true)
      div = browser.div(:id => 'foo')
      expect(div.outer_html).to eq('<div id="foo"><a href="#">hello</a></div>')
    end
  end
end
