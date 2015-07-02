tequire File.expand_path("../spec_helper", __FILE__)

describe "Browser::Checkers" do
  describe "#add" do
    it "raises ArgumentError when not given any arguments" do
      expect { browser.checkers.add }.to raise_error(ArgumentError)
    end

    it "runs the given proc on each page load" do
      output = ''
      proc = Proc.new { |browser| output << browser.text }

      begin
        browser.checkers.add(proc)
        browser.goto(WatirSpec.url_for("non_control_elements.html"))

        expect(output).to include('Dubito, ergo cogito, ergo sum')
      ensure
        browser.checkers.delete(proc)
      end
    end
  end

  describe "#delete" do
    it "removes a previously added checker" do
      output = ''
      checker = lambda{ |browser| output << browser.text }

      browser.checkers.add(checker)
      browser.goto(WatirSpec.url_for("non_control_elements.html"))
      expect(output).to include('Dubito, ergo cogito, ergo sum')

      browser.checkers.delete(checker)
      browser.goto(WatirSpec.url_for("definition_lists.html"))
      expect(output).to_not include('definition_lists')
    end
  end

  describe "#run" do
    after(:each) do
      browser.window(index: 0).use
      browser.alert.close if browser.alert.exists?
      browser.checkers.delete @page_checker
    end

    it "runs checkers after Browser#goto" do
      @page_checker = Proc.new { @yield = browser.title == "The font element" }
      browser.checkers.add @page_checker
      browser.goto WatirSpec.url_for("font.html")
      expect(@yield).to be true
    end

    it "runs checkers after Browser#refresh" do
      browser.goto WatirSpec.url_for("font.html")
      @page_checker = Proc.new { @yield = browser.title == "The font element" }
      browser.checkers.add @page_checker
      browser.refresh
      expect(@yield).to be true
    end

    it "runs checkers after Element#click" do
      browser.goto(WatirSpec.url_for("non_control_elements.html"))
      @page_checker = Proc.new { @yield = browser.title == "Non-control elements" }
      browser.checkers.add @page_checker
      browser.link(index: 1).click
      expect(@yield).to be true
    end

    not_compliant_on %i(webdriver iphone) do
      it "runs checkers after Element#double_click" do
        browser.goto(WatirSpec.url_for("non_control_elements.html"))
        @page_checker = Proc.new { @yield = browser.title == "Non-control elements" }
        browser.checkers.add @page_checker
        browser.div(id: 'html_test').double_click
        expect(@yield).to be true
      end
    end

    it "runs checkers after Element#right_click" do
      browser.goto(WatirSpec.url_for("right_click.html"))
      @page_checker = Proc.new { @yield = browser.title == "Right Click Test" }
      browser.checkers.add @page_checker
      browser.div(id: "click").right_click
      expect(@yield).to be true
    end

    it "raises UnhandledAlertError error when running error checks with alert present" do
      url = WatirSpec.url_for("alerts.html")
      @page_checker = Proc.new { browser.url }
      browser.checkers.add @page_checker
      browser.goto url
      expect { browser.button(id: "alert").click }.to raise_error(Selenium::WebDriver::Error::UnhandledAlertError)
    end

    it "does not raise error when running error checks using #checkers.without with alert present" do
      url = WatirSpec.url_for("alerts.html")
      @page_checker = Proc.new { browser.url }
      browser.checkers.add @page_checker
      browser.goto url
      expect { browser.checkers.without {browser.button(id: "alert").click} }.to_not raise_error
    end

    it "does not raise error if no error checks are defined with alert present" do
      url = WatirSpec.url_for("alerts.html")
      @page_checker = Proc.new { browser.url }
      browser.checkers.add @page_checker
      browser.goto url
      browser.checkers.delete @page_checker
      expect { browser.button(id: "alert").click }.to_not raise_error
      browser.alert.close
    end

    it "does not raise error when running error checks on closed window" do
      url = WatirSpec.url_for("window_switching.html")
      @page_checker = Proc.new { browser.url }
      browser.checkers.add @page_checker
      browser.goto url
      browser.a(id: "open").click

      window = browser.window(title: "closeable window")
      window.use
      expect { browser.a(id: "close").click }.to_not raise_error
      browser.window(index: 0).use
    end
  end
end
