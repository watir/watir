require File.expand_path('watirspec/spec_helper', File.dirname(__FILE__))

describe Watir::Element do

  describe '#send_keys' do
    before(:each) { browser.goto('file://' + File.expand_path('html/keylogger.html', File.dirname(__FILE__))) }

    let(:receiver) { browser.element(:id => 'receiver')       }
    let(:events)   { browser.element(:id => 'output').ps.size }

    it 'sends keystrokes to the element' do
      receiver.send_keys 'hello world'
      receiver.value.should == 'hello world'
      events.should == 11
    end

    it 'accepts arbitrary list of arguments' do
      receiver.send_keys 'hello', 'world'
      receiver.value.should == 'helloworld'
      events.should == 10
    end

    it 'performs key combinations' do
      receiver.send_keys 'foo'
      receiver.send_keys [:control, 'a']
      receiver.send_keys :backspace
      receiver.value.should be_empty
      events.should == 6
    end

    it 'performs arbitrary list of key combinations' do
      receiver.send_keys 'foo'
      receiver.send_keys [:control, 'a'], [:control, 'x']
      receiver.value.should be_empty
      events.should == 7
    end

    it 'supports combination of strings and arrays' do
      receiver.send_keys 'foo', [:control, 'a'], :backspace
      receiver.value.should be_empty
      events.should == 6
    end
  end

  describe '#present?' do
    before do
      browser.goto('file://' + File.expand_path('html/wait.html', File.dirname(__FILE__)))
    end

    it 'returns true if the element exists and is visible' do
      browser.div(:id, 'foo').should be_present
    end

    it 'returns false if the element exists but is not visible' do
      browser.div(:id, 'bar').should_not be_present
    end

    it 'returns false if the element does not exist' do
      browser.div(:id, 'should-not-exist').should_not be_present
    end
  end

end
