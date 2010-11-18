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
      @container.public_extract_selector([:how, 'what']).
                 should == { :how => 'what' }
    end

    it "returns the hash given" do
      @container.public_extract_selector([:how => "what"]).
                 should == { :how => "what" }
    end

    it "returns an empty hash if given no args" do
      @container.public_extract_selector([]).should == {}
    end

    it "raises ArgumentError if given 1 arg which is not a Hash" do
      lambda {
        @container.public_extract_selector([:how])
      }.should raise_error(ArgumentError)
    end

    it "raises ArgumentError if given > 2 args" do
      lambda {
        @container.public_extract_selector([:how, 'what', 'value'])
      }.should raise_error(ArgumentError)
    end

  end
end
