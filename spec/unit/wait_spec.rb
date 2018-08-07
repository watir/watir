require_relative 'unit_helper'

describe Watir::Wait do
  describe '#until' do
    it 'waits until the block returns true' do
      Watir::Wait.until(timeout: 0.5) { @result = true }
      expect(@result).to be true
    end

    it 'executes block if timeout is zero' do
      Watir::Wait.until(timeout: 0) { @result = true }
      expect(@result).to be true
    end

    it 'times out' do
      expect { Watir::Wait.until(timeout: 0.5) { false } }.to raise_error(Watir::Wait::TimeoutError)
    end

    it 'times out with a custom message' do
      expect {
        Watir::Wait.until(timeout: 0.5, message: 'oops') { false }
      }.to raise_error(Watir::Wait::TimeoutError, 'timed out after 0.5 seconds, oops')
    end

    it 'uses provided interval' do
      expect {
        Watir::Wait.until(timeout: 0.4, interval: 0.2) do
          @result = @result.nil? ? 1 : @result + 1
          false
        end
      }.to raise_timeout_exception
      expect(@result).to eq 2
    end

    it 'uses timer for waiting' do
      timer = Watir::Wait.timer
      expect(timer).to receive(:wait).with(0.5).and_call_original
      Watir::Wait.until(timeout: 0.5) { true }
    end
  end

  describe '#while' do
    it 'waits while the block returns true' do
      expect(Watir::Wait.while(timeout: 0.5) { false }).to be_nil
    end

    it 'executes block if timeout is zero' do
      expect(Watir::Wait.while(timeout: 0) { false }).to be_nil
    end

    it 'times out' do
      expect { Watir::Wait.while(timeout: 0.5) { true } }.to raise_error(Watir::Wait::TimeoutError)
    end

    it 'times out with a custom message' do
      expect {
        Watir::Wait.while(timeout: 0.5, message: 'oops') { true }
      }.to raise_error(Watir::Wait::TimeoutError, 'timed out after 0.5 seconds, oops')
    end

    it 'uses provided interval' do
      expect {
        Watir::Wait.while(timeout: 0.4, interval: 0.2) do
          @result = @result.nil? ? 1 : @result + 1
          true
        end
      }.to raise_timeout_exception
      expect(@result).to eq 2
    end

    it 'uses timer for waiting' do
      timer = Watir::Wait.timer
      expect(timer).to receive(:wait).with(0.5).and_call_original
      Watir::Wait.while(timeout: 0.5) { false }
    end
  end

  describe '#timer' do
    it 'returns default timer' do
      expect(Watir::Wait.timer).to be_a(Watir::Wait::Timer)
    end
  end

  describe '#timer=' do
    after { Watir::Wait.timer = nil }

    it 'changes default timer' do
      timer = Class.new
      Watir::Wait.timer = timer
      expect(Watir::Wait.timer).to eq(timer)
    end
  end
end
