require File.expand_path('watirspec/spec_helper', File.dirname(__FILE__))

describe 'Watir' do
  describe '#relaxed_locate?' do

    before do
      browser.goto WatirSpec.url_for("wait.html")
    end

    it 'Raises Exception when Element not found' do
      exception = Watir::Exception::UnknownObjectException
      message = /unable to locate element: {:id=>"not_present", :tag_name=>"input or textarea", :type=>"\(any text type\)"} after waiting 1 seconds/
      begin
        @original_timeout = Watir.default_timeout
        Watir.default_timeout = 1
        expect { browser.text_field(id: "not_present").click }.to raise_exception(exception, message)
      ensure
        Watir.default_timeout = @original_timeout
      end
    end

    it "Returns a warning after a full sleep waiting to find element" do
      warning = "This test has slept for the duration of the default timeout. If your test is passing, consider using Element#exists? instead of rescuing this error\n"
      begin
        @original_timeout = Watir.default_timeout
        Watir.default_timeout = 1
        expect do
          begin
            browser.text_field(id: "not_present").click
          rescue Watir::Exception::UnknownObjectException
          end
        end.to output(warning).to_stderr
      ensure
        Watir.default_timeout = @original_timeout
      end
    end

    it "Does not return a warning when unable to find an element using #without_waiting" do
      expect do
        begin
          browser.without_waiting { browser.text_field(id: "not_present").click }
        rescue Watir::Exception::UnknownObjectException
        end
      end.to_not output.to_stderr
    end

    it 'Raises Exception when Element not present' do
      browser.a(id: 'hide_foo').click
      browser.div(id: 'foo').wait_while_present

      exception = Watir::Exception::UnknownObjectException
      message = /element located but not visible: {:id=>"foo", :tag_name=>"div"} after waiting 1 seconds/
      begin
        @original_timeout = Watir.default_timeout
        Watir.default_timeout = 1
        expect { browser.div(id: 'foo').click }.to raise_exception(exception, message)
      ensure
        Watir.default_timeout = @original_timeout
      end
    end

    it "Returns a warning after a full sleep waiting to for an element to become present" do
      browser.a(id: 'hide_foo').click
      browser.div(id: 'foo').wait_while_present

      warning = "This test has slept for the duration of the default timeout. If your test is passing, consider using Element#present? instead of rescuing this error\n"
      begin
        @original_timeout = Watir.default_timeout
        Watir.default_timeout = 1
        expect do
          begin
            browser.div(id: 'foo').click
          rescue Watir::Exception::UnknownObjectException
          end
        end.to output(warning).to_stderr
      ensure
        Watir.default_timeout = @original_timeout
      end
    end

    it "Does not return a warning when an element does not become present using #without_waiting" do
      expect do
        begin
          browser.without_waiting { browser.div(id: 'foo').click }
        rescue Watir::Exception::UnknownObjectException
        end
      end.to_not output.to_stderr
    end

    it "Returns a warning that using #when_present might be unnecessary" do
      begin
        warning = /#when_present might be unnecessary for {:id=>"hide_foo", :tag_name=>"a"}; Watir automatically waits when using #click/
        @original_timeout = Watir.default_timeout
        Watir.default_timeout = 1
        expect do
          browser.a(id: 'hide_foo').when_present.click
        end.to output(warning).to_stderr
      ensure
        Watir.default_timeout = @original_timeout
      end
    end

    it 'Raises Exception when Window not found' do
      exception = Watir::Exception::NoMatchingWindowFoundException
      message = /unable to locate window: {:title=>"No"} after waiting 1 seconds/
      begin
        @original_timeout = Watir.default_timeout
        Watir.default_timeout = 1
        expect { browser.window(title: "No").use }.to raise_exception(exception, message)
      ensure
        Watir.default_timeout = @original_timeout
      end
    end

    it "Returns a warning after a full sleep waiting to find window" do
      warning = "This test has slept for the duration of the default timeout. If your test is passing, consider using Window#exists? instead of rescuing this error\n"
      begin
        @original_timeout = Watir.default_timeout
        Watir.default_timeout = 1
        expect do
          begin
            browser.window(title: "No").use
          rescue Watir::Exception::NoMatchingWindowFoundException
          end
        end.to output(warning).to_stderr
      ensure
        Watir.default_timeout = @original_timeout
      end
    end

    it "Does not return a warning when unable to find a window if using #without_waiting" do
      expect do
        begin
          browser.without_waiting { browser.window(title: "No").use }
        rescue Watir::Exception::NoMatchingWindowFoundException
        end
      end.to_not output.to_stderr
    end

    it 'Raises Exception when Alert not found' do
      exception = Watir::Exception::UnknownObjectException
      message = /unable to locate alert after waiting 1 seconds/
      begin
        @original_timeout = Watir.default_timeout
        Watir.default_timeout = 1
        expect { browser.alert.text }.to raise_exception(exception, message)
      ensure
        Watir.default_timeout = @original_timeout
      end
    end

    it "Returns a warning after a full sleep waiting to find alert" do
      warning = "This test has slept for the duration of the default timeout. If your test is passing, consider using Alert#exists? instead of rescuing this error\n"
      begin
        @original_timeout = Watir.default_timeout
        Watir.default_timeout = 1
        expect do
          begin
            browser.alert.text
          rescue Watir::Exception::UnknownObjectException
          end
        end.to output(warning).to_stderr
      ensure
        Watir.default_timeout = @original_timeout
      end
    end

    it "Does not return a warning when unable to find an alert if using #without_waiting" do
      expect do
        begin
          browser.without_waiting { browser.alert.text }
        rescue Watir::Exception::UnknownObjectException
        end
      end.to_not output.to_stderr
    end

  end
end
