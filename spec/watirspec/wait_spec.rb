# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

not_compliant_on :safari do
  describe Watir::Wait do
    describe "#until" do
      it "returns result of block if truthy" do
        result = 'catter'
        expect(Wait.until(0.5) { result }).to be result
      end

      it "waits until the block returns true" do
        expect(Wait.until(0.5) { true }).to be true
      end

      it "executes block if timeout is zero" do
        expect(Wait.until(0) { true }).to be true
      end

      it "times out" do
        expect {Wait.until(0.5) { false }}.to raise_error(Watir::Wait::TimeoutError)
      end

      it "times out with a custom message" do
        expect {
          Wait.until(0.5, "oops") { false }
        }.to raise_error(Watir::Wait::TimeoutError, "timed out after 0.5 seconds, oops")
      end

      it "uses timer for waiting" do
        timer = Wait.timer
        expect(timer).to receive(:wait).with(0.5).and_call_original
        Wait.until(0.5) { true }
      end
    end

    describe "#while" do
      it "waits while the block returns true" do
        expect(Wait.while(0.5) { false }).to be_nil
      end

      it "executes block if timeout is zero" do
        expect(Wait.while(0) { false }).to be_nil
      end

      it "times out" do
        expect {Wait.while(0.5) { true }}.to raise_error(Watir::Wait::TimeoutError)
      end

      it "times out with a custom message" do
        expect {
          Wait.while(0.5, "oops") { true }
        }.to raise_error(Watir::Wait::TimeoutError, "timed out after 0.5 seconds, oops")
      end

      it "uses timer for waiting" do
        timer = Wait.timer
        expect(timer).to receive(:wait).with(0.5).and_call_original
        Wait.while(0.5) { false }
      end
    end

    describe "#timer" do
      it "returns default timer" do
        expect(Wait.timer).to be_a(Wait::Timer)
      end
    end

    describe "#timer=" do
      after { Wait.timer = nil }

      it "changes default timer" do
        timer = Class.new
        Wait.timer = timer
        expect(Wait.timer).to eq(timer)
      end
    end
  end

  describe Watir::Element do
    before do
      browser.goto WatirSpec.url_for("wait.html")
    end

    describe "#when_present" do
      it "yields when the element becomes present" do
        called = false

        browser.a(id: 'show_bar').click
        browser.div(id: 'bar').when_present(2) { called = true }

        expect(called).to be true
      end

      it "invokes subsequent method calls when the element becomes present" do
        browser.a(id: 'show_bar').click

        bar = browser.div(id: 'bar')
        bar.when_present(2).click
        expect(bar.text).to eq "changed"
      end

      it "times out when given a block" do
        expect { browser.div(id: 'bar').when_present(1) {}}.to raise_error(Watir::Wait::TimeoutError)
      end

      it "times out when not given a block" do
        expect { browser.div(id: 'bar').when_present(1).click }.to raise_error(Watir::Wait::TimeoutError,
          /^timed out after 1 seconds, waiting for (\{:id=>"bar", :tag_name=>"div"\}|\{:tag_name=>"div", :id=>"bar"\}) to become present$/
        )
      end

      it "responds to Element methods" do
        decorator = browser.div.when_present

        expect(decorator).to respond_to(:exist?)
        expect(decorator).to respond_to(:present?)
        expect(decorator).to respond_to(:click)
      end

      it "delegates present? to element" do
        Object.class_eval do
          def present?
            false
          end
        end
        element = browser.a(id: "show_bar").when_present(1)
        expect(element).to be_present
      end

      it "processes before calling present?" do
        browser.a(id: 'show_bar').click
        expect(browser.div(id: 'bar').when_present.present?).to be true
      end

    end

    describe "#when_enabled" do
      it "yields when the element becomes enabled" do
        called = false

        browser.a(id: 'enable_btn').click
        browser.button(id: 'btn').when_enabled(2) { called = true }

        expect(called).to be true
      end

      it "invokes subsequent method calls when the element becomes enabled" do
        browser.a(id: 'enable_btn').click

        btn = browser.button(id: 'btn')
        btn.when_enabled(2).click
        expect(btn.disabled?).to be true
      end

      it "times out when given a block" do
        expect { browser.button(id: 'btn').when_enabled(1) {}}.to raise_error(Watir::Wait::TimeoutError)
      end

      it "times out when not given a block" do
        expect { browser.button(id: 'btn').when_enabled(1).click }.to raise_error(Watir::Wait::TimeoutError,
          /^timed out after 1 seconds, waiting for (\{:id=>"btn", :tag_name=>"button"\}|\{:tag_name=>"button", :id=>"btn"\}) to become enabled$/
        )
      end

      it "times out when not given a block" do
        expect { browser.button(id: 'btn').when_enabled(1).click }.to raise_error(Watir::Wait::TimeoutError,
          /timed out after 1 seconds, waiting for {:id=>"btn", :tag_name=>"button"} to become enabled$/
        )
      end

      it "responds to Element methods" do
        decorator = browser.button.when_enabled

        expect(decorator).to respond_to(:exist?)
        expect(decorator).to respond_to(:present?)
        expect(decorator).to respond_to(:click)
      end

      it "can be chained with #when_present" do
        browser.a(id: 'show_and_enable_btn').click
        browser.button(id: 'btn2').when_present(1).when_enabled(1).click

        expect(browser.button(id: 'btn2')).to exist
        expect(browser.button(id: 'btn2')).to be_enabled
      end
    end

    describe "#wait_until_present" do
      it "it waits until the element appears" do
        browser.a(id: 'show_bar').click
        expect { browser.div(id: 'bar').wait_until_present(5) }.to_not raise_exception
      end

      it "times out if the element doesn't appear" do
        expect { browser.div(id: 'bar').wait_until_present(1) }.to raise_error(Watir::Wait::TimeoutError,
          /^timed out after 1 seconds, waiting for (\{:id=>"bar", :tag_name=>"div"\}|\{:tag_name=>"div", :id=>"bar"\}) to become present$/
        )
      end

    end

    describe "#wait_while_present" do
      it "waits until the element disappears" do
        browser.a(id: 'hide_foo').click
        expect { browser.div(id: 'foo').wait_while_present(1) }.to_not raise_exception
      end

      it "times out if the element doesn't disappear" do
        expect { browser.div(id: 'foo').wait_while_present(1) }.to raise_error(Watir::Wait::TimeoutError,
          /^timed out after 1 seconds, waiting for (\{:id=>"foo", :tag_name=>"div"\}|\{:tag_name=>"div", :id=>"foo"\}) to disappear$/
        )
      end
    end

    describe "#wait_until_stale" do
      it "waits until the element disappears" do
        stale_element = browser.div(id: 'foo')
        stale_element.exists?
        browser.refresh
        expect { stale_element.wait_until_stale(1) }.to_not raise_exception
      end

      it "times out if the element doesn't go stale" do

        element = browser.div(id: 'foo')
        element.exists?
        expect { element.wait_until_stale(1) }.to raise_error(Watir::Wait::TimeoutError,
                                                              /^timed out after 1 seconds, waiting for (\{:id=>"foo", :tag_name=>"div"\}|\{:tag_name=>"div", :id=>"foo"\}) to become stale$/
        )
      end
    end
  end

  describe "Watir.default_timeout" do
    before do
      Watir.default_timeout = 1

      browser.goto WatirSpec.url_for("wait.html")
    end

    after do
      # Reset the default timeout
      Watir.default_timeout = 30
    end

    context "when no timeout is specified" do
      it "is used by Wait#until" do
        expect {
          Wait.until { false }
        }.to raise_error(Watir::Wait::TimeoutError)
      end

      it "is used by Wait#while" do
        expect {
          Wait.while { true }
        }.to raise_error(Watir::Wait::TimeoutError)
      end

      it "is used by Element#when_present" do
        expect {
          browser.div(id: 'bar').when_present.click
        }.to raise_error(Watir::Wait::TimeoutError)
      end

      it "is used by Element#wait_until_present" do
        expect {
          browser.div(id: 'bar').wait_until_present
        }.to raise_error(Watir::Wait::TimeoutError)
      end

      it "is used by Element#wait_while_present" do
        expect {
          browser.div(id: 'foo').wait_while_present
        }.to raise_error(Watir::Wait::TimeoutError)
      end
    end
  end
end
