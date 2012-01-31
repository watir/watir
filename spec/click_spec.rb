require File.expand_path('../watirspec/spec_helper', __FILE__)

describe Watir::Element do
  describe "#click" do
    before {
      browser.goto WatirSpec.url_for('clicks.html', :needs_server => true)
    }

    let(:clicker) { browser.element(:id => "click-logger") }
    let(:log)     { browser.element(:id => "log").ps.map { |e| e.text } }

    # TODO: make guards more flexible, in reality this currently only works on linux with native events
    compliant_on [:webdriver, :firefox, :native_events] do 
      it "should perform a click with no modifier keys" do
        clicker.click
        log.should == ["shift=false alt=false"]
      end

      it "should perform a click with the shift key pressed" do
        clicker.click(:shift)
        log.should == ["shift=true alt=false"]
      end

      it "should perform a click with the alt key pressed" do
        clicker.click(:alt)
        log.should == ["shift=false alt=true"]
      end

      it "should perform a click with the shift and alt keys pressed" do
        clicker.click(:shift, :alt)
        log.should == ["shift=true alt=true"]
      end
    end

  end
end
