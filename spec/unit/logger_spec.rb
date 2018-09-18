require_relative 'unit_helper'

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

    it 'allows to change level with integer' do
      Watir.logger.level = 3
      expect(Watir.logger.level).to eq(3)
    end

    it 'outputs to stdout by default' do
      expect { Watir.logger.warn('message') }.to output(/WARN Watir message/).to_stdout_from_any_process
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
      expect { Watir.logger.deprecate('#old', '#new') }.to output(message).to_stdout_from_any_process
    end

    it 'allows to selectively ignore deprecations with Strings' do
      Watir.logger.ignore('old deprecated')
      expect { Watir.logger.deprecate('#old', '#new', ids: ['old deprecated']) }
        .to_not output.to_stdout_from_any_process
    end

    it 'allows to selectively ignore deprecations with Symbols' do
      Watir.logger.ignore(:foo)
      expect { Watir.logger.deprecate('#old', '#new', ids: [:foo]) }.to_not output.to_stdout_from_any_process
    end

    it 'allows to selectively ignore warnings with Strings' do
      Watir.logger.ignore(:foo)
      expect { Watir.logger.warn('warning', ids: ['foo']) }.to_not output.to_stdout_from_any_process
    end

    it 'allows to selectively ignore warnings with Symbols' do
      Watir.logger.ignore(:foo)
      expect { Watir.logger.warn('warning', ids: [:foo]) }.to_not output.to_stdout_from_any_process
    end

    it 'allows to ignore all deprecation notices' do
      Watir.logger.ignore(:deprecations)
      expect { Watir.logger.deprecate('#old', '#new') }.to_not output.to_stdout_from_any_process
    end

    it 'allows to ignore multiple ids' do
      Watir.logger.ignore(%i[foo bar])
      expect { Watir.logger.warn('warning', ids: [:foo]) }.to_not output.to_stdout_from_any_process
      expect { Watir.logger.warn('warning', ids: [:bar]) }.to_not output.to_stdout_from_any_process
    end
  end
end
