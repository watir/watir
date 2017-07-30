require 'watirspec_helper'

module Watir
  describe Logger do
    around do |example|
      debug = $DEBUG
      $DEBUG = false
      example.call
      $DEBUG = debug
      Watir.instance_variable_set(:@logger, nil) # reset cache
    end

    it 'logs warnings by default' do
      expect(Watir.logger.level).to eq(2)
    end

    it 'logs everything if $DEBUG is set to true' do
      $DEBUG = true
      expect(Watir.logger.level).to eq(0)
    end

    it 'allows to change level during execution' do
      Watir.logger.level = :info
      expect(Watir.logger.level).to eq(1)
    end

    it 'outputs to stdout by default' do
      expect { Watir.logger.warn('message') }.to output(/WARN Watir message/).to_stdout
    end

    it 'allows to output to file' do
      begin
        Watir.logger.output = 'test.log'
        Watir.logger.warn('message')
        expect(File.read('test.log')).to include('WARN Watir message')
      ensure
        File.delete('test.log')
      end
    end

    it 'allows to deprecate functionality' do
      message = /WARN Watir \[DEPRECATION\] #old is deprecated\. Use #new instead\./
      expect { Watir.logger.deprecate('#old', '#new') }.to output(message).to_stdout
    end
  end
end
