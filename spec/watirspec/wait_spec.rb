require "watirspec_helper"

not_compliant_on :safari do
  module Watir
    describe Wait do
      describe "#until" do
        it "waits until the block returns true" do
          Wait.until(timeout: 0.5) { @result = true }
          expect(@result).to be true
        end

        it "executes block if timeout is zero" do
          Wait.until(timeout: 0) { @result = true }
          expect(@result).to be true
        end

        it "times out" do
          expect { Wait.until(timeout: 0.5) { false } }.to raise_error(Wait::TimeoutError)
        end

        it "times out with a custom message" do
          expect {
            Wait.until(timeout: 0.5, message: "oops") { false }
          }.to raise_error(Wait::TimeoutError, "timed out after 0.5 seconds, oops")
        end

        it "uses timer for waiting" do
          timer = Wait.timer
          expect(timer).to receive(:wait).with(0.5).and_call_original
          Wait.until(timeout: 0.5) { true }
        end

        it "ordered pairs are deprecated" do
          message = /Instead of passing arguments into Wait#until method, use keywords/
          expect { Wait.until(0) { true } }.to output(message).to_stderr
        end
      end

      describe "#while" do
        it "waits while the block returns true" do
          expect(Wait.while(timeout: 0.5) { false }).to be_nil
        end

        it "executes block if timeout is zero" do
          expect(Wait.while(timeout: 0) { false }).to be_nil
        end

        it "times out" do
          expect { Wait.while(timeout: 0.5) { true } }.to raise_error(Wait::TimeoutError)
        end

        it "times out with a custom message" do
          expect {
            Wait.while(timeout: 0.5, message: "oops") { true }
          }.to raise_error(Wait::TimeoutError, "timed out after 0.5 seconds, oops")
        end

        it "uses timer for waiting" do
          timer = Wait.timer
          expect(timer).to receive(:wait).with(0.5).and_call_original
          Wait.while(timeout: 0.5) { false }
        end

        it "ordered pairs are deprecated" do
          message = /Instead of passing arguments into Wait#while method, use keywords/
          expect { Wait.while(0) { false } }.to output(message).to_stderr
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

    describe Element do
      before do
        browser.goto WatirSpec.url_for("wait.html")
      end

      describe "#when_present" do
        context 'warnings' do
          it 'received for using #when_present' do
            message = /when_present has been deprecated and is unlikely to be needed; replace this with #wait_until_present if a wait is still needed/
            browser.a(id: 'show_bar').click
            expect do
              browser.div(id: 'bar').when_present.click
            end.to output(message).to_stderr
          end
        end

        not_compliant_on :relaxed_locate do
          context 'deprecated' do
            it "invokes subsequent method calls when the element becomes present" do
              browser.a(id: 'show_bar').click

              bar = browser.div(id: 'bar')
              bar.when_present(2).click
              expect(bar.text).to eq "changed"
            end

            it "times out when given a block" do
              expect { browser.div(id: 'bar').when_present(1) {} }.to raise_error(Wait::TimeoutError)
            end

            it "times out when not given a block" do
              message = /^timed out after 1 seconds, waiting for (\{:id=>"bar", :tag_name=>"div"\}|\{:tag_name=>"div", :id=>"bar"\}) to become present$/
              expect { browser.div(id: 'bar').when_present(1).click }.to raise_error(Wait::TimeoutError, message)
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
        end

        not_compliant_on :relaxed_locate do
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
              Wait.while { btn.enabled? }
              expect(btn.disabled?).to be true
            end

            it "times out when given a block" do
              expect { browser.button(id: 'btn').when_enabled(1) {} }.to raise_error(Wait::TimeoutError)
            end

            it "times out when not given a block" do
              message = /^timed out after 1 seconds, waiting for (\{:id=>"btn", :tag_name=>"button"\}|\{:tag_name=>"button", :id=>"btn"\}) to become enabled$/
              expect { browser.button(id: 'btn').when_enabled(1).click }.to raise_error(Wait::TimeoutError, message)
            end

            it "times out when not given a block" do
              message = /timed out after 1 seconds, waiting for {:id=>"btn", :tag_name=>"button"} to become enabled$/
              expect { browser.button(id: 'btn').when_enabled(1).click }.to raise_error(Wait::TimeoutError, message)
            end

            it "responds to Element methods" do
              decorator = browser.button.when_enabled

              expect(decorator).to respond_to(:exist?)
              expect(decorator).to respond_to(:present?)
              expect(decorator).to respond_to(:click)
            end

            it "can be chained with #when_present" do
              browser.a(id: 'show_and_enable_btn').click
              browser.button(id: 'btn2').when_present(5).when_enabled(5).click

              expect(browser.button(id: 'btn2')).to exist
              expect(browser.button(id: 'btn2')).to be_enabled
            end
          end
        end

        describe "#wait_until_present" do
          it "it waits until the element appears" do
            browser.a(id: 'show_bar').click
            expect { browser.div(id: 'bar').wait_until_present(timeout: 5) }.to_not raise_exception
          end

          it "times out if the element doesn't appear" do
            message = /^timed out after 1 seconds, waiting for true condition on (\{:id=>"bar", :tag_name=>"div"\}|\{:tag_name=>"div", :id=>"bar"\})$/
            expect { browser.div(id: 'bar').wait_until_present(timeout: 1) }.to raise_error(Wait::TimeoutError, message)
          end

          it "ordered pairs are deprecated" do
            browser.a(id: 'show_bar').click
            message = /Instead of passing arguments into #wait_until_present method, use keywords/
            expect { browser.div(id: 'bar').wait_until_present(5) }.to output(message).to_stderr
          end
        end

        describe "#wait_while_present" do
          it "waits until the element disappears" do
            browser.a(id: 'hide_foo').click
            expect { browser.div(id: 'foo').wait_while_present(timeout: 1) }.to_not raise_exception
          end

          it "times out if the element doesn't disappear" do
            message = /^timed out after 1 seconds, waiting for false condition on (\{:id=>"foo", :tag_name=>"div"\}|\{:tag_name=>"div", :id=>"foo"\})$/
            expect { browser.div(id: 'foo').wait_while_present(timeout: 1) }.to raise_error(Wait::TimeoutError, message)
          end

          it "ordered pairs are deprecated" do
            browser.a(id: 'hide_foo').click
            message = /Instead of passing arguments into #wait_while_present method, use keywords/
            expect { browser.div(id: 'foo').wait_while_present(5) }.to output(message).to_stderr
          end
        end

        describe "#wait_until" do
          it "returns element for additional actions" do
            element = browser.div(id: 'foo')
            expect(element.wait_until(&:exist?)).to eq element
          end

          it "accepts self in block" do
            element = browser.div(id: 'bar')
            browser.a(id: 'show_bar').click
            expect { element.wait_until { |el| el.text == 'bar' } }.to_not raise_exception
          end

          it "accepts any values in block" do
            element = browser.div(id: 'bar')
            expect { element.wait_until { true } }.to_not raise_exception
          end

          it "accepts just a timeout parameter" do
            element = browser.div(id: 'bar')
            expect { element.wait_until(timeout: 0) { true } }.to_not raise_exception
          end

          it "accepts just a message parameter" do
            element = browser.div(id: 'bar')
            expect { element.wait_until(message: 'no') { true } }.to_not raise_exception
          end
        end

        describe "#wait_while" do
          it "returns element for additional actions" do
            element = browser.div(id: 'foo')
            browser.a(id: 'hide_foo').click
            expect(element.wait_while(&:present?)).to eq element
          end

          it "accepts self in block" do
            element = browser.div(id: 'foo')
            browser.a(id: 'hide_foo').click
            expect { element.wait_while { |el| el.text == 'foo' } }.to_not raise_exception
          end

          it "accepts any values in block" do
            element = browser.div(id: 'foo')
            expect { element.wait_while { false } }.to_not raise_exception
          end

          it "accepts just a timeout parameter" do
            element = browser.div(id: 'foo')
            expect { element.wait_while(timeout: 0) { false } }.to_not raise_exception
          end

          it "accepts just a message parameter" do
            element = browser.div(id: 'foo')
            expect { element.wait_while(message: 'no') { false } }.to_not raise_exception
          end
        end
      end
    end

    describe Watir do
      describe "#default_timeout" do
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
            }.to raise_error(Wait::TimeoutError)
          end

          it "is used by Wait#while" do
            expect {
              Wait.while { true }
            }.to raise_error(Wait::TimeoutError)
          end

          it "is used by Element#wait_until_present" do
            expect {
              browser.div(id: 'bar').wait_until_present
            }.to raise_error(Wait::TimeoutError)
          end

          it "is used by Element#wait_while_present" do
            expect {
              browser.div(id: 'foo').wait_while_present
            }.to raise_error(Wait::TimeoutError)
          end
        end
      end
    end
  end
end
