require "base64"
require File.expand_path("../spec_helper", __FILE__)

describe "Watir::Screenshot" do
  describe '#png' do
    it 'gets png representation of screenshot' do
      browser.screenshot.png[0..3].should == "\211PNG"
    end
  end

  describe '#base64' do
    it 'gets base64 representation of screenshot' do
      image = browser.screenshot.base64
      Base64.decode64(image)[0..3].should == "\211PNG"
    end
  end

  describe '#save' do
    it 'saves screenshot to given file' do
      path = "#{Dir.tmpdir}/test#{Time.now.to_i}.png"
      File.should_not exist(path)
      browser.screenshot.save(path)
      File.should exist(path)
      File.open(path, "rb") {|io| io.read}[0..3].should == "\211PNG"
    end
  end
end
