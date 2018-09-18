require 'watirspec_helper'

describe Watir::UserEditable do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  not_compliant_on :safari do
    describe '#append' do
      it 'appends the text to the text field' do
        browser.text_field(name: 'new_user_occupation').append(' Append This')
        expect(browser.text_field(name: 'new_user_occupation').value).to eq 'Developer Append This'
      end

      it 'appends multi-byte characters' do
        browser.text_field(name: 'new_user_occupation').append(' ĳĳ')
        expect(browser.text_field(name: 'new_user_occupation').value).to eq 'Developer ĳĳ'
      end

      it 'raises NotImplementedError if the object is content editable element' do
        msg = '#append method is not supported with contenteditable element'
        expect { browser.div(id: 'contenteditable').append('bar') }.to raise_exception(NotImplementedError, msg)
      end

      it 'raises ObjectReadOnlyException if the object is read only' do
        expect { browser.text_field(id: 'new_user_code').append('Append This') }.to raise_object_read_only_exception
      end

      it 'raises ObjectDisabledException if the object is disabled' do
        expect { browser.text_field(name: 'new_user_species').append('Append This') }.to raise_object_disabled_exception
      end

      it "raises UnknownObjectException if the object doesn't exist" do
        expect { browser.text_field(name: 'no_such_name').append('Append This') }.to raise_unknown_object_exception
      end
    end
  end

  describe '#clear' do
    it 'removes all text from the text field' do
      browser.text_field(name: 'new_user_occupation').clear
      expect(browser.text_field(name: 'new_user_occupation').value).to be_empty
      browser.textarea(id: 'delete_user_comment').clear
      expect(browser.textarea(id: 'delete_user_comment').value).to be_empty
    end

    it 'removes all text from the content editable element' do
      browser.div(id: 'contenteditable').clear
      expect(browser.div(id: 'contenteditable').text).to eq ''
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(id: 'no_such_id').clear }.to raise_unknown_object_exception
    end

    it 'raises ObjectReadOnlyException if the object is read only' do
      expect { browser.text_field(id: 'new_user_code').clear }.to raise_object_read_only_exception
    end
  end

  describe '#value=' do
    it 'sets the value of the element' do
      browser.text_field(id: 'new_user_email').value = 'Hello Cruel World'
      expect(browser.text_field(id: 'new_user_email').value).to eq 'Hello Cruel World'
    end

    it 'is able to set multi-byte characters' do
      browser.text_field(name: 'new_user_occupation').value = 'ĳĳ'
      expect(browser.text_field(name: 'new_user_occupation').value).to eq 'ĳĳ'
    end

    it 'sets the value of a textarea element' do
      browser.textarea(id: 'delete_user_comment').value = 'Hello Cruel World'
      expect(browser.textarea(id: 'delete_user_comment').value).to eq 'Hello Cruel World'
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(name: 'no_such_name').value = 'yo' }.to raise_unknown_object_exception
    end
  end

  describe '#set' do
    it 'sets the value of the element' do
      browser.text_field(id: 'new_user_email').set('Bye Cruel World')
      expect(browser.text_field(id: 'new_user_email').value).to eq 'Bye Cruel World'
    end

    it 'sets the value of a textarea element' do
      browser.textarea(id: 'delete_user_comment').set('Hello Cruel World')
      expect(browser.textarea(id: 'delete_user_comment').value).to eq 'Hello Cruel World'
    end

    it 'sets the value of a content editable element' do
      browser.div(id: 'contenteditable').set('Bar')
      expect(browser.div(id: 'contenteditable').text).to eq 'Bar'
    end

    it 'fires events' do
      browser.text_field(id: 'new_user_username').set('Hello World')
      expect(browser.span(id: 'current_length').text).to eq '11'
    end

    it 'sets the value of a password field' do
      browser.text_field(name: 'new_user_password').set('secret')
      expect(browser.text_field(name: 'new_user_password').value).to eq 'secret'
    end

    it 'sets the value when accessed through the enclosing Form' do
      browser.form(id: 'new_user').text_field(name: 'new_user_password').set('secret')
      expect(browser.form(id: 'new_user').text_field(name: 'new_user_password').value).to eq 'secret'
    end

    it 'is able to set multi-byte characters' do
      browser.text_field(name: 'new_user_occupation').set('ĳĳ')
      expect(browser.text_field(name: 'new_user_occupation').value).to eq 'ĳĳ'
    end

    it 'sets the value to a concatenation of multiple arguments' do
      browser.text_field(id: 'new_user_email').set('Bye', 'Cruel', 'World')
      expect(browser.text_field(id: 'new_user_email').value).to eq 'ByeCruelWorld'
    end

    it 'sets the value to blank when no arguments are provided' do
      browser.text_field(id: 'new_user_email').set
      expect(browser.text_field(id: 'new_user_email').value).to eq ''
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(id: 'no_such_id').set('secret') }.to raise_unknown_object_exception
    end

    it 'raises ObjectReadOnlyException if the object is read only' do
      expect { browser.text_field(id: 'new_user_code').set('Foo') }.to raise_object_read_only_exception
    end
  end

  describe '#set!' do
    it 'sets the value of the element' do
      browser.text_field(id: 'new_user_email').set!('Bye Cruel World')
      expect(browser.text_field(id: 'new_user_email').value).to eq 'Bye Cruel World'
    end

    it 'sets the value of a textarea element' do
      browser.textarea(id: 'delete_user_comment').set!('Hello Cruel World')
      expect(browser.textarea(id: 'delete_user_comment').value).to eq 'Hello Cruel World'
    end

    it 'sets the value of a content editable element' do
      browser.div(id: 'contenteditable').set!('foo')
      expect(browser.div(id: 'contenteditable').text).to eq 'foo'
    end

    it 'fires events' do
      browser.text_field(id: 'new_user_username').set!('Hello World')
      expect(browser.span(id: 'current_length').text).to eq '11'
    end

    it 'sets the value of a password field' do
      browser.text_field(name: 'new_user_password').set!('secret')
      expect(browser.text_field(name: 'new_user_password').value).to eq 'secret'
    end

    it 'sets the value when accessed through the enclosing Form' do
      browser.form(id: 'new_user').text_field(name: 'new_user_password').set!('secret')
      expect(browser.form(id: 'new_user').text_field(name: 'new_user_password').value).to eq 'secret'
    end

    it 'is able to set multi-byte characters' do
      browser.text_field(name: 'new_user_occupation').set!('ĳĳ')
      expect(browser.text_field(name: 'new_user_occupation').value).to eq 'ĳĳ'
    end

    it 'sets the value to a concatenation of multiple arguments' do
      browser.text_field(id: 'new_user_email').set!('Bye', 'Cruel', 'World')
      expect(browser.text_field(id: 'new_user_email').value).to eq 'ByeCruelWorld'
    end

    it 'sets the value to blank when no arguments are provided' do
      browser.text_field(id: 'new_user_email').set!
      expect(browser.text_field(id: 'new_user_email').value).to eq ''
    end

    it 'raises ArgumentError for special keys' do
      expect { browser.text_field(id: 'new_user_email').set!('a', :tab) }.to raise_error(ArgumentError)
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(id: 'no_such_id').set!('secret') }.to raise_unknown_object_exception
    end

    it "raises Exception if the value of text field doesn't match" do
      element = browser.text_field(id: 'new_user_password')
      allow(element).to receive(:value).and_return('wrong')
      msg = "#set! value: 'wrong' does not match expected input: 'secret'"
      expect { element.set!('secret') }.to raise_exception(Watir::Exception::Error, msg)
    end

    it "raises Exception if the text of content editable element doesn't match" do
      element = browser.div(id: 'contenteditable')
      allow(element).to receive(:text).and_return('wrong')
      msg = "#set! text: 'wrong' does not match expected input: 'secret'"
      expect { element.set!('secret') }.to raise_exception(Watir::Exception::Error, msg)
    end
  end
end
