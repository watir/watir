require 'watir-webdriver'

#
# 1. If example does not start browser, start new one, reuse until example
#    finishes and close after
# 2. If example starts browser and assigns it to local variable `browser`,
#    it will still be closed
#

def browser
  @browser ||= Watir::Browser.new
end

YARD::Doctest.after do
  browser.quit
  @browser = nil
end
