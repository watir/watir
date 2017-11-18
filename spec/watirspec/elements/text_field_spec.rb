require "watirspec_helper"

describe "TextField" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  # Exists method
  describe "#exists?" do
    it "returns true if the element exists" do
      expect(browser.text_field(id: 'new_user_email')).to exist
      expect(browser.text_field(id: /new_user_email/)).to exist
      expect(browser.text_field(name: 'new_user_email')).to exist
      expect(browser.text_field(name: /new_user_email/)).to exist
      expect(browser.text_field(value: 'Developer')).to exist
      expect(browser.text_field(value: /Developer/)).to exist
      expect(browser.text_field(text: 'Developer')).to exist
      expect(browser.text_field(text: /Developer/)).to exist
      expect(browser.text_field(class: 'name')).to exist
      expect(browser.text_field(class: /name/)).to exist
      expect(browser.text_field(index: 0)).to exist
      expect(browser.text_field(xpath: "//input[@id='new_user_email']")).to exist
      expect(browser.text_field(label: "First name")).to exist
      expect(browser.text_field(label: /(Last|First) name/)).to exist
      expect(browser.text_field(label: 'Without for')).to exist
      expect(browser.text_field(label: /Without for/)).to exist
    end

    it "returns the first text field if given no args" do
      expect(browser.text_field).to exist
    end

    it "respects text fields types" do
      expect(browser.text_field.type).to eq('text')
    end

    it "returns true if the element exists (no type attribute)" do
      expect(browser.text_field(id: 'new_user_first_name')).to exist
    end

    it "returns true if the element exists (invalid type attribute)" do
      expect(browser.text_field(id: 'new_user_last_name')).to exist
    end

    it "returns true for element with upper case type" do
      expect(browser.text_field(id: "new_user_email_confirm")).to exist
    end

    it "returns true for element with unknown type attribute" do
      expect(browser.text_field(id: "unknown_text_field")).to exist
    end

    it "returns false if the element does not exist" do
      expect(browser.text_field(id: 'no_such_id')).to_not exist
      expect(browser.text_field(id: /no_such_id/)).to_not exist
      expect(browser.text_field(name: 'no_such_name')).to_not exist
      expect(browser.text_field(name: /no_such_name/)).to_not exist
      expect(browser.text_field(value: 'no_such_value')).to_not exist
      expect(browser.text_field(value: /no_such_value/)).to_not exist
      expect(browser.text_field(text: 'no_such_text')).to_not exist
      expect(browser.text_field(text: /no_such_text/)).to_not exist
      expect(browser.text_field(class: 'no_such_class')).to_not exist
      expect(browser.text_field(class: /no_such_class/)).to_not exist
      expect(browser.text_field(index: 1337)).to_not exist
      expect(browser.text_field(xpath: "//input[@id='no_such_id']")).to_not exist
      expect(browser.text_field(label: "bad label")).to_not exist
      expect(browser.text_field(label: /bad label/)).to_not exist

      # input type='hidden' should not be found by #text_field
      expect(browser.text_field(id: "new_user_interests_dolls")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.text_field(id: 3.14).exists? }.to raise_error(TypeError)
    end
  end

  # Attribute methods
  describe "#id" do
    it "returns the id attribute if the text field exists" do
      expect(browser.text_field(index: 4).id).to eq "new_user_occupation"
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(index: 1337).id }.to raise_unknown_object_exception
    end
  end

  describe "#name" do
    it "returns the name attribute if the text field exists" do
      expect(browser.text_field(index: 3).name).to eq "new_user_email_confirm"
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(index: 1337).name }.to raise_unknown_object_exception
    end
  end

  describe "#title" do
    it "returns the title attribute if the text field exists" do
      expect(browser.text_field(id: "new_user_code").title).to eq "Your personal code"
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(index: 1337).title }.to raise_unknown_object_exception
    end
  end

  describe "#type" do
    it "returns the type attribute if the text field exists" do
      expect(browser.text_field(index: 3).type).to eq "text"
    end

    it "returns 'text' if the type attribute is invalid" do
      expect(browser.text_field(id: 'new_user_last_name').type).to eq "text"
    end

    it "returns 'text' if the type attribute does not exist" do
      expect(browser.text_field(id: 'new_user_first_name').type).to eq "text"
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(index: 1337).type }.to raise_unknown_object_exception
    end
  end

  describe "#value" do
    it "returns the value attribute if the text field exists" do
      expect(browser.text_field(name: "new_user_occupation").value).to eq "Developer"
      expect(browser.text_field(index: 4).value).to eq "Developer"
      expect(browser.text_field(name: /new_user_occupation/i).value).to eq "Developer"
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(index: 1337).value }.to raise_unknown_object_exception
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      expect(browser.text_field(index: 0)).to respond_to(:class_name)
      expect(browser.text_field(index: 0)).to respond_to(:id)
      expect(browser.text_field(index: 0)).to respond_to(:name)
      expect(browser.text_field(index: 0)).to respond_to(:title)
      expect(browser.text_field(index: 0)).to respond_to(:type)
      expect(browser.text_field(index: 0)).to respond_to(:value)
    end
  end

  # Access methods
  describe "#enabled?" do
    it "returns true for enabled text fields" do
      expect(browser.text_field(name: "new_user_occupation")).to be_enabled
      expect(browser.text_field(id: "new_user_email")).to be_enabled
    end

    it "returns false for disabled text fields" do
      expect(browser.text_field(name: "new_user_species")).to_not be_enabled
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(id: "no_such_id").enabled? }.to raise_unknown_object_exception
    end
  end

  describe "#disabled?" do
    it "returns true if the text field is disabled" do
      expect(browser.text_field(id: 'new_user_species')).to be_disabled
    end

    it "returns false if the text field is enabled" do
      expect(browser.text_field(index: 0)).to_not be_disabled
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(index: 1337).disabled? }.to raise_unknown_object_exception
    end
  end

  describe "#readonly?" do
    it "returns true for read-only text fields" do
      expect(browser.text_field(name: "new_user_code")).to be_readonly
      expect(browser.text_field(id: "new_user_code")).to be_readonly
    end

    it "returns false for writable text fields" do
      expect(browser.text_field(name: "new_user_email")).to_not be_readonly
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(id: 'no_such_id').readonly? }.to raise_unknown_object_exception
    end

    it "raises UnknownReadOnlyException if sending keys to readonly element" do
      expect { browser.text_field(id: 'new_user_code').set 'foo' }.to raise_object_read_only_exception
    end
  end

  # Manipulation methods
  not_compliant_on :safari do
    describe "#append" do
      it "appends the text to the text field" do
        browser.text_field(name: "new_user_occupation").append(" Append This")
        expect(browser.text_field(name: "new_user_occupation").value).to eq "Developer Append This"
      end

      it "appends multi-byte characters" do
        browser.text_field(name: "new_user_occupation").append(" ĳĳ")
        expect(browser.text_field(name: "new_user_occupation").value).to eq "Developer ĳĳ"
      end

      it "raises ObjectReadOnlyException if the object is read only" do
        expect { browser.text_field(id: "new_user_code").append("Append This") }.to raise_object_read_only_exception
      end

      it "raises ObjectDisabledException if the object is disabled" do
        expect { browser.text_field(name: "new_user_species").append("Append This") }.to raise_object_disabled_exception
      end

      it "raises UnknownObjectException if the object doesn't exist" do
        expect { browser.text_field(name: "no_such_name").append("Append This") }.to raise_unknown_object_exception
      end
    end
  end

  describe "#clear" do
    it "removes all text from the text field" do
      browser.text_field(name: "new_user_occupation").clear
      expect(browser.text_field(name: "new_user_occupation").value).to be_empty
      browser.textarea(id: "delete_user_comment").clear
      expect(browser.textarea(id: "delete_user_comment").value).to be_empty
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(id: "no_such_id").clear }.to raise_unknown_object_exception
    end

    it "raises ObjectReadOnlyException if the object is read only" do
      expect { browser.text_field(id: "new_user_code").clear }.to raise_object_read_only_exception
    end
  end

  describe "#value=" do
    it "sets the value of the element" do
      browser.text_field(id: 'new_user_email').value = 'Hello Cruel World'
      expect(browser.text_field(id: "new_user_email").value).to eq 'Hello Cruel World'
    end

    it "is able to set multi-byte characters" do
      browser.text_field(name: "new_user_occupation").value = "ĳĳ"
      expect(browser.text_field(name: "new_user_occupation").value).to eq "ĳĳ"
    end

    it "sets the value of a textarea element" do
      browser.textarea(id: 'delete_user_comment').value = 'Hello Cruel World'
      expect(browser.textarea(id: "delete_user_comment").value).to eq 'Hello Cruel World'
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(name: "no_such_name").value = 'yo' }.to raise_unknown_object_exception
    end
  end

  describe "#set" do
    it "sets the value of the element" do
      browser.text_field(id: 'new_user_email').set('Bye Cruel World')
      expect(browser.text_field(id: "new_user_email").value).to eq 'Bye Cruel World'
    end

    it "sets the value of a textarea element" do
      browser.textarea(id: 'delete_user_comment').set('Hello Cruel World')
      expect(browser.textarea(id: "delete_user_comment").value).to eq 'Hello Cruel World'
    end

    it "fires events" do
      browser.text_field(id: "new_user_username").set("Hello World")
      expect(browser.span(id: "current_length").text).to eq "11"
    end

    it "sets the value of a password field" do
      browser.text_field(name: 'new_user_password').set('secret')
      expect(browser.text_field(name: 'new_user_password').value).to eq 'secret'
    end

    it "sets the value when accessed through the enclosing Form" do
      browser.form(id: 'new_user').text_field(name: 'new_user_password').set('secret')
      expect(browser.form(id: 'new_user').text_field(name: 'new_user_password').value).to eq 'secret'
    end

    it "is able to set multi-byte characters" do
      browser.text_field(name: "new_user_occupation").set("ĳĳ")
      expect(browser.text_field(name: "new_user_occupation").value).to eq "ĳĳ"
    end

    it "sets the value to a concatenation of multiple arguments" do
      browser.text_field(id: 'new_user_email').set('Bye', 'Cruel', 'World')
      expect(browser.text_field(id: "new_user_email").value).to eq 'ByeCruelWorld'
    end

    it "sets the value to blank when no arguments are provided" do
      browser.text_field(id: 'new_user_email').set
      expect(browser.text_field(id: "new_user_email").value).to eq ''
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(id: "no_such_id").set('secret') }.to raise_unknown_object_exception
    end
  end

  describe "#set!" do
    it "sets the value of the element" do
      browser.text_field(id: 'new_user_email').set!('Bye Cruel World')
      expect(browser.text_field(id: "new_user_email").value).to eq 'Bye Cruel World'
    end

    it "sets the value of a textarea element" do
      browser.textarea(id: 'delete_user_comment').set!('Hello Cruel World')
      expect(browser.textarea(id: "delete_user_comment").value).to eq 'Hello Cruel World'
    end

    it "fires events" do
      browser.text_field(id: "new_user_username").set!("Hello World")
      expect(browser.span(id: "current_length").text).to eq "11"
    end

    it "sets the value of a password field" do
      browser.text_field(name: 'new_user_password').set!('secret')
      expect(browser.text_field(name: 'new_user_password').value).to eq 'secret'
    end

    it "sets the value when accessed through the enclosing Form" do
      browser.form(id: 'new_user').text_field(name: 'new_user_password').set!('secret')
      expect(browser.form(id: 'new_user').text_field(name: 'new_user_password').value).to eq 'secret'
    end

    it "is able to set multi-byte characters" do
      browser.text_field(name: "new_user_occupation").set!("ĳĳ")
      expect(browser.text_field(name: "new_user_occupation").value).to eq "ĳĳ"
    end

    it "sets the value to a concatenation of multiple arguments" do
      browser.text_field(id: 'new_user_email').set!('Bye', 'Cruel', 'World')
      expect(browser.text_field(id: "new_user_email").value).to eq 'ByeCruelWorld'
    end

    it "sets the value to blank when no arguments are provided" do
      browser.text_field(id: 'new_user_email').set!
      expect(browser.text_field(id: "new_user_email").value).to eq ''
    end

    it "raises ArgumentError for special keys" do
      expect { browser.text_field(id: 'new_user_email').set!('a', :tab) }.to raise_error(ArgumentError)
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.text_field(id: "no_such_id").set!('secret') }.to raise_unknown_object_exception
    end
  end
end
