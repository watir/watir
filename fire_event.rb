fire_event = File.read(File.expand_path("../lib/watir/atoms/fireEvent.js", __FILE__))
script = "return (%s).apply(null, arguments)" % fire_event

require 'selenium-webdriver'
driver = Selenium::WebDriver.for :chrome
driver.navigate.to "http://google.com"
element = driver.find_element(id: 'lst-ib')
$DEBUG = true
driver.execute_script(script, element, 'focus')
