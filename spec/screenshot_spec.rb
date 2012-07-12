require File.expand_path("watirspec/spec_helper", File.dirname(__FILE__))

describe Watir::Screenshot do
  describe '#png' do
    it 'gets png representation of screenshot from WebDriver' do
      browser.driver.should_receive(:screenshot_as).with(:png)
      browser.screenshot.png
    end
  end

  describe '#base64' do
    it 'gets base64 representation of screenshot from WebDriver' do
      browser.driver.should_receive(:screenshot_as).with(:base64)
      browser.screenshot.base64
    end
  end

  describe '#save' do
    it 'saves screenshot to given file' do
      path = "#{Dir.tmpdir}/test.png"
      browser.driver.should_receive(:save_screenshot).with(path)
      browser.screenshot.save(path)
    end
  end
end
