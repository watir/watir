# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

not_compliant_on [:webdriver, :safari] do
  describe Watir::Wait do
    describe "#until" do
      it "waits until the block returns true" do
        expect(Wait.until(0.5) { true }).to be true
      end

      it "times out" do
        expect {Wait.until(0.5) { false }}.to raise_error(Watir::Wait::TimeoutError)
      end

      it "times out with a custom message" do
        expect {
          Wait.until(0.5, "oops") { false }
        }.to raise_error(Watir::Wait::TimeoutError, "timed out after 0.5 seconds, oops")
      end
    end

    describe "#while" do
      it "waits while the block returns true" do
        expect(Wait.while(0.5) { false }).to be_nil
      end

      it "times out" do
        expect {Wait.while(0.5) { true }}.to raise_error(Watir::Wait::TimeoutError)
      end

      it "times out with a custom message" do
        expect {
          Wait.while(0.5, "oops") { true }
        }.to raise_error(Watir::Wait::TimeoutError, "timed out after 0.5 seconds, oops")
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

       expect(called).to be true
      end

      it "invokes subsequent method calls when the element becomes present" do
        browser.a(:id, 'show_bar').click

        bar = browser.div(:id, 'bar')
        bar.when_present(2).click
        expect(bar.text).to eq "changed"
      end

      it "times out when given a block" do
        expect { browser.div(:id, 'bar').when_present(1) {}}.to raise_error(Watir::Wait::TimeoutError)
      end

      not_compliant_on :watir_classic do
        it "times out when not given a block" do
          expect { browser.div(:id, 'bar').when_present(1).click }.to raise_error(Watir::Wait::TimeoutError,
            /^timed out after 1 seconds, waiting for (\{:id=>"bar", :tag_name=>"div"\}|\{:tag_name=>"div", :id=>"bar"\}) to become present$/
          )
        end
      end

      deviates_on :watir_classic do
        it "times out when not given a block" do
          expect { browser.div(:id, 'bar').when_present(1).click }.to raise_error(Watir::Wait::TimeoutError,
            /^timed out after 1 seconds, waiting for (\{:id=>"bar", :tag_name=>\["div"\]\}|\{:tag_name=>\["div"\], :id=>"bar"\}) to become present$/
          )
        end
      end

      it "responds to Element methods" do
        decorator = browser.div.when_present

        decorator.should respond_to(:exist?)
        decorator.should respond_to(:present?)
        decorator.should respond_to(:click)
      end

      it "delegates present? to element" do
        Object.class_eval do
          def present?
            false
          end
        end
        element = browser.a(:id, "show_bar").when_present(1)
        expect(element).to be_present
      end
    end

    describe "#wait_until_present" do
      it "it waits until the element appears" do
        browser.a(:id, 'show_bar').click
        browser.div(:id, 'bar').wait_until_present(5)
      end

      not_compliant_on :watir_classic do
        it "times out if the element doesn't appear" do
          expect { browser.div(:id, 'bar').wait_until_present(1) }.to raise_error(Watir::Wait::TimeoutError,
            /^timed out after 1 seconds, waiting for (\{:id=>"bar", :tag_name=>"div"\}|\{:tag_name=>"div", :id=>"bar"\}) to become present$/
          )
        end
      end

      deviates_on :watir_classic do
        it "times out if the element doesn't appear" do
          expect { browser.div(:id, 'bar').wait_until_present(1) }.to raise_error(Watir::Wait::TimeoutError,
            /^timed out after 1 seconds, waiting for (\{:id=>"bar", :tag_name=>\["div"\]\}|\{:tag_name=>\["div"\], :id=>"bar"\}) to become present$/
          )
        end
      end
    end

    describe "#wait_while_present" do
      it "waits until the element disappears" do
        browser.a(:id, 'hide_foo').click
        browser.div(:id, 'foo').wait_while_present(1)
      end

      not_compliant_on :watir_classic do
        it "times out if the element doesn't disappear" do
          expect { browser.div(:id, 'foo').wait_while_present(1) }.to raise_error(Watir::Wait::TimeoutError,
            /^timed out after 1 seconds, waiting for (\{:id=>"foo", :tag_name=>"div"\}|\{:tag_name=>"div", :id=>"foo"\}) to disappear$/
          )
        end
      end

      deviates_on :watir_classic do
        it "times out if the element doesn't disappear" do
          expect { browser.div(:id, 'foo').wait_while_present(1) }.to raise_error(Watir::Wait::TimeoutError,
            /^timed out after 1 seconds, waiting for (\{:id=>"foo", :tag_name=>\["div"\]\}|\{:tag_name=>\["div"\], :id=>"foo"\}) to disappear$/
          )
        end
      end
    end
  end

  describe "Watir.default_timeout" do
    before do
      Watir.default_timeout = 1

      browser.goto WatirSpec.url_for("wait.html", :needs_server => true)
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
          browser.div(:id, 'bar').when_present.click
        }.to raise_error(Watir::Wait::TimeoutError)
      end

      it "is used by Element#wait_until_present" do
        expect {
          browser.div(:id, 'bar').wait_until_present
        }.to raise_error(Watir::Wait::TimeoutError)
      end

      it "is used by Element#wait_while_present" do
        expect {
          browser.div(:id, 'foo').wait_while_present
        }.to raise_error(Watir::Wait::TimeoutError)
      end
    end
  end
end
