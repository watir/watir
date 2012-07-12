require File.expand_path("watirspec/spec_helper", File.dirname(__FILE__))

not_compliant_on [:webdriver, :safari] do
  describe Watir::Wait do
    describe "#until" do
      it "waits until the block returns true" do
        Wait.until(0.5) { true }.should be_true
      end

      it "times out" do
        lambda do
          Wait.until(0.5) { false }
        end.should raise_error(Watir::Wait::TimeoutError)
      end

      it "times out with a custom message" do
        lambda do
          Wait.until(0.5, "oops") { false }
        end.should raise_error(Watir::Wait::TimeoutError, "timed out after 0.5 seconds, oops")
      end
    end

    describe "#while" do
      it "waits while the block returns true" do
        Wait.while(0.5) { false }.should == nil
      end

      it "times out" do
        lambda do
          Wait.while(0.5) { true }
        end.should raise_error(Watir::Wait::TimeoutError)
      end

      it "times out with a custom message" do
        lambda do
          Wait.while(0.5, "oops") { true }
        end.should raise_error(Watir::Wait::TimeoutError, "timed out after 0.5 seconds, oops")
      end
    end
  end

  describe Watir::Element do
    before do
      browser.goto WatirSpec.url_for("wait.html", :needs_server => true)
    end

    describe "#when_present" do
      it "yields when the element becomes present" do
        called = false

        browser.a(:id, 'show_bar').click
        browser.div(:id, 'bar').when_present(2) { called = true }

        called.should be_true
      end

      it "invokes subsequent method calls when the element becomes present" do
        browser.a(:id, 'show_bar').click

        bar = browser.div(:id, 'bar')
        bar.when_present(2).click
        bar.text.should == "changed"
      end

      it "times out when given a block" do
        lambda {
          browser.div(:id, 'bar').when_present(1) {}
        }.should raise_error(Watir::Wait::TimeoutError)
      end

      it "times out when not given a block" do
        lambda {
          browser.div(:id, 'bar').when_present(1).click
        }.should raise_error(Watir::Wait::TimeoutError,
          /^timed out after 1 seconds, waiting for (\{:id=>"bar", :tag_name=>"div"\}|\{:tag_name=>"div", :id=>"bar"\}) to become present$/
        )
      end

      it "responds to Element methods" do
        decorator = browser.div.when_present

        decorator.should respond_to(:exist?)
        decorator.should respond_to(:present?)
        decorator.should respond_to(:click)
      end
    end

    describe "#wait_until_present" do
      it "it waits until the element appears" do
        browser.a(:id, 'show_bar').click
        browser.div(:id, 'bar').wait_until_present(5)
      end

      it "times out if the element doesn't appear" do
        lambda do
          browser.div(:id, 'bar').wait_until_present(1)
        end.should raise_error(Watir::Wait::TimeoutError,
          /^timed out after 1 seconds, waiting for (\{:id=>"bar", :tag_name=>"div"\}|\{:tag_name=>"div", :id=>"bar"\}) to become present$/
        )
      end
    end

    describe "#wait_while_present" do
      it "waits until the element disappears" do
        browser.a(:id, 'hide_foo').click
        browser.div(:id, 'foo').wait_while_present(1)
      end

      it "times out" do
        lambda do
          browser.div(:id, 'foo').wait_while_present(1)
        end.should raise_error(Watir::Wait::TimeoutError,
          /^timed out after 1 seconds, waiting for (\{:id=>"foo", :tag_name=>"div"\}|\{:tag_name=>"div", :id=>"foo"\}) to disappear$/
        )
      end
    end
  end
end
