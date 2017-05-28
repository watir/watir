require "base64"
require "watirspec_helper"

describe "Watir::Screenshot" do
  let(:png_header) { "\211PNG".force_encoding('ASCII-8BIT') }

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
      assert_saves_png_file(path) do
        browser.screenshot.save(path)
      end
    end

    it 'saves a file to a path without extension' do
      path = "#{Dir.tmpdir}/test#{Time.now.to_i}"
      assert_saves_png_file(path) do
        browser.screenshot.save(path)
      end
    end

    it 'saves a file to a path with an uppercase PNG extension' do
      path = "#{Dir.tmpdir}/test#{Time.now.to_i}.PNG"
      assert_saves_png_file(path) do
        browser.screenshot.save(path)
      end
    end

    it 'raises an ArgumentError if extension of provided file is not png' do
      path = "#{Dir.tmpdir}/test#{Time.now.to_i}.jpg"
      expect do
        browser.screenshot.save(path)
      end.to raise_error(ArgumentError)
    end

    def assert_saves_png_file(path)
      expect(File).to_not exist(path)
      yield
      expect(File).to exist(path)
      expect(File.open(path, "rb") { |io| io.read }[0..3]).to eq png_header
    end
  end
end
