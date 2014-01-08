require File.expand_path('watirspec/spec_helper', File.dirname(__FILE__))

describe Watir::Container do
  before { @container = Object.new.extend(Watir::Container) }

  describe "#extract_selector" do
    before do
      def @container.public_extract_selector(*args)
        extract_selector(*args)
      end
    end

    it "converts 2-arg selector into a hash" do
      expect(@container.public_extract_selector([:how, 'what'])).to eq Hash[:how => 'what']
    end

    it "returns the hash given" do
      expect(@container.public_extract_selector([:how => "what"])).to eq Hash[:how => "what"]
    end

    it "returns an empty hash if given no args" do
      expect(@container.public_extract_selector([])).to eq Hash[]
    end

    it "raises ArgumentError if given 1 arg which is not a Hash" do
      expect {@container.public_extract_selector([:how])}.to raise_error(ArgumentError)
    end

    it "raises ArgumentError if given > 2 args" do
      expect {@container.public_extract_selector([:how, 'what', 'value'])}.to raise_error(ArgumentError)
    end

  end
end
