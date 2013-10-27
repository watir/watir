require "base64"
require File.expand_path("../spec_helper", __FILE__)

describe "Watir::Screenshot" do
  let(:png_header) do
    str = "\211PNG"
    str.force_encoding('BINARY') if str.respond_to?(:force_encoding)

    str
  end

  describe '#png' do
    it 'gets png representation of screenshot' do
      expect(browser.screenshot.png[0..3]).to eq png_header
    end
  end

  describe '#base64' do
    it 'gets base64 representation of screenshot' do
      image = browser.screenshot.base64
      expect(Base64.decode64(image)[0..3]).to eq png_header
    end
  end

  describe '#save' do
    it 'saves screenshot to given file' do
      path = "#{Dir.tmpdir}/test#{Time.now.to_i}.png"
      expect(File).to_not exist(path)
      browser.screenshot.save(path)
      expect(File).to exist(path)
      expect(File.open(path, "rb") {|io| io.read}[0..3]).to eq png_header
    end
  end
end
