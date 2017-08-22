require "watirspec_helper"

describe "RadioSet" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  # Exists method
  describe "#exists?" do
    it "returns true if matches any particular radio_set button" do
      expect(browser.radio_set(id: "new_user_newsletter_yes")).to exist
      expect(browser.radio_set(id: /new_user_newsletter_yes/)).to exist
      expect(browser.radio_set(name: "new_user_newsletter")).to exist
      expect(browser.radio_set(name: /new_user_newsletter/)).to exist
      expect(browser.radio_set(value: "yes")).to exist
      expect(browser.radio_set(value: /yes/)).to exist
      expect(browser.radio_set(class: "huge")).to exist
      expect(browser.radio_set(class: /huge/)).to exist
      expect(browser.radio_set(index: 0)).to exist
      expect(browser.radio_set(xpath: "//input[@id='new_user_newsletter_yes']")).to exist
    end

    it "returns the first radio set if given no args" do
      expect(browser.radio_set).to exist
    end

    it "returns false if no radio button exists" do
      expect(browser.radio_set(id: "no_such_id")).to_not exist
      expect(browser.radio_set(id: /no_such_id/)).to_not exist
      expect(browser.radio_set(name: "no_such_name")).to_not exist
      expect(browser.radio_set(name: /no_such_name/)).to_not exist
      expect(browser.radio_set(value: "no_such_value")).to_not exist
      expect(browser.radio_set(value: /no_such_value/)).to_not exist
      expect(browser.radio_set(text: "no_such_text")).to_not exist
      expect(browser.radio_set(text: /no_such_text/)).to_not exist
      expect(browser.radio_set(class: "no_such_class")).to_not exist
      expect(browser.radio_set(class: /no_such_class/)).to_not exist
      expect(browser.radio_set(index: 1337)).to_not exist
      expect(browser.radio_set(xpath: "input[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect {browser.radio_set(id: 3.14).exists?}.to raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      expect {browser.radio_set(no_such_how: 'some_value').exists?}.to raise_error(Watir::Exception::MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#name" do
    it "returns the name attribute if the radio exists" do
      expect(browser.radio_set(id: 'new_user_newsletter_yes').name).to eq "new_user_newsletter"
    end

    it "returns an empty string if the radio exists and the attribute doesn't" do
      expect(browser.radio_set(id: 'new_user_newsletter_absolutely').name).to eq ""
    end

    it "raises UnknownObjectException if the radio doesn't exist" do
      expect {browser.radio_set(index: 1337).name}.to raise_unknown_object_exception
    end
  end

  describe "#type" do
    it "returns the type attribute if the radio set exists" do
      expect(browser.radio_set.type).to eq "radio"
    end

    it "raises UnknownObjectException if the radio doesn't exist" do
      expect {browser.radio_set(index: 1337).type}.to raise_unknown_object_exception
    end
  end

  describe "#value" do
    it "returns the value attributes of the selected radio button" do
      expect(browser.radio_set(id: 'new_user_newsletter_yes').value).to eq 'yes'
    end

    it "raises UnknownObjectException if the radio doesn't exist" do
      expect {browser.radio_set(index: 1337).value}.to raise_unknown_object_exception
    end
  end

  describe "#text" do
    it "returns the text of the selected radio button" do
      expect(browser.radio_set(id: 'new_user_newsletter_yes').text).to eq 'Yes'
    end

    it "raises UnknownObjectException if the radio set doesn't exist" do
      expect {browser.radio_set(index: 1337).text}.to raise_unknown_object_exception
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      expect(browser.radio_set(index: 0)).to_not respond_to(:class_name)
      expect(browser.radio_set(index: 0)).to_not respond_to(:id)
      expect(browser.radio_set(index: 0)).to respond_to(:name)
      expect(browser.radio_set(index: 0)).to_not respond_to(:title)
      expect(browser.radio_set(index: 0)).to respond_to(:type)
      expect(browser.radio_set(index: 0)).to respond_to(:value)
      expect(browser.radio_set(index: 0)).to respond_to(:text)
      expect(browser.radio_set(index: 0)).to_not respond_to(:clear)
    end
  end

  # Access methods
  describe "#enabled?" do
    it "returns true if any radio button in the set is enabled" do
      expect(browser.radio_set(id: "new_user_newsletter_nah")).to be_enabled
      expect(browser.radio_set(xpath: "//input[@id='new_user_newsletter_nah']")).to be_enabled
    end

    it "returns false if all radio buttons are disabled" do
      expect(browser.radio_set(id: "new_user_newsletter_none")).to_not be_enabled
      expect(browser.radio_set(xpath: "//input[@id='new_user_newsletter_none']")).to_not be_enabled
    end

    it "raises UnknownObjectException if the radio button doesn't exist" do
      expect {browser.radio_set(id: "no_such_id").enabled?}.to raise_unknown_object_exception
      expect {browser.radio_set(xpath: "//input[@id='no_such_id']").enabled?}.to raise_unknown_object_exception
    end
  end

  describe "#disabled?" do
    it "returns false if the any radio button in the set is enabled" do
      expect(browser.radio_set(id: "new_user_newsletter_nah")).to_not be_disabled
      expect(browser.radio_set(xpath: "//input[@id='new_user_newsletter_nah']")).to_not be_disabled
    end

    it "returns true if all radio buttons are disabled" do
      expect(browser.radio_set(id: "new_user_newsletter_none")).to be_disabled
      expect(browser.radio_set(xpath: "//input[@id='new_user_newsletter_none']")).to be_disabled
    end

    it "should raise UnknownObjectException when the radio set does not exist" do
      expect {browser.radio_set(index: 1337).disabled?}.to raise_unknown_object_exception
    end
  end

  # Other
  describe "#radio" do
    it "returns an instance of Radio" do
      radio = browser.radio_set(id: 'new_user_newsletter_yes').radio(id: 'new_user_newsletter_no')
      expect(radio).to be_instance_of(Watir::Radio)
      expect(radio.value).to eq "no"
    end
  end

  describe "#radios" do
    it "returns collection of all radios in the set" do
      radios = browser.radio_set(id: 'new_user_newsletter_yes').radios
      values = %w[yes no certainly nah nah]
      expect(radios.map(&:value)).to match_array values
    end
  end

  describe "#selected" do
    it "should raise UnknownObjectException if the radio set doesn't exist" do
      expect {browser.radio_set(name: 'no_such_name').selected}.to raise_unknown_object_exception
    end

    it "gets the currently selected radio" do
      expect(browser.radio_set(id: 'new_user_newsletter_no').selected.text).to eq 'Yes'
      expect(browser.radio_set(id: 'new_user_newsletter_no').selected.value).to eq 'yes'
    end
  end

  describe "#include?" do
    it "returns true if the given radio exists by text" do
      expect(browser.radio_set(id: 'new_user_newsletter_no')).to include('Yes')
    end

    it "returns false if the given option doesn't exist" do
      expect(browser.radio_set(id: 'new_user_newsletter_no')).to_not include('Mother')
    end
  end

  describe "#selected?" do
    it "returns true if the given option is selected by text" do
      browser.radio_set(id: 'new_user_newsletter_yes').select('No')
      expect(browser.radio_set(id: 'new_user_newsletter_yes')).to be_selected('No')
    end

    it "returns false if the given option is not selected by text" do
      expect(browser.radio_set(id: 'new_user_newsletter_yes')).to_not be_selected('Probably')
    end

    it "raises UnknownObjectException if the radio button doesn't exist" do
      expect {browser.radio_set(id: 'new_user_newsletter_yes').selected?('missing_option')}.to raise_unknown_object_exception
    end
  end

  describe "#select" do
    context "when interacting with radios" do
      it "selects radio text by String" do
        browser.radio_set(id: 'new_user_newsletter_yes').select("Probably")
        expect(browser.radio_set(id: 'new_user_newsletter_yes').selected.text).to eq 'Probably'
      end

      it "selects radio text by Regexp" do
        browser.radio_set(id: 'new_user_newsletter_yes').select(/Prob/)
        expect(browser.radio_set(id: 'new_user_newsletter_yes').selected.text).to eq 'Probably'
      end

      it "selects the radio text when given an Xpath" do
        browser.radio_set(xpath: "//input[@id='new_user_newsletter_no']").select("Probably")
        expect(browser.radio_set(xpath: "//input[@id='new_user_newsletter_no']").selected.text).to eq 'Probably'
      end

      it "selects radio value by string" do
        browser.radio_set(id: 'new_user_newsletter_yes').select("no")
        expect(browser.radio_set(id: 'new_user_newsletter_yes').selected.text).to eq 'No'
      end

      it "selects radio value by regexp" do
        browser.radio_set(id: 'new_user_newsletter_yes').select(/nah/)
        expect(browser.radio_set(id: 'new_user_newsletter_yes').selected.text).to eq 'Probably'
      end
    end

    it "returns the value selected" do
      expect(browser.radio_set(id: 'new_user_newsletter_yes').select("no")).to eq "no"
    end

    it "fires onchange event when selecting a radio" do
      browser.radio_set(id: 'new_user_newsletter_yes').radio(value: 'certainly').set
      expect(messages).to eq ["changed: new_user_newsletter"]

      browser.radio_set(id: 'new_user_newsletter_yes').radio(value: 'certainly').set
      expect(messages).to eq ["changed: new_user_newsletter"] # no event fired here - didn't change

      browser.radio_set(id: 'new_user_newsletter_yes').radio(value: 'yes').set
      browser.radio_set(id: 'new_user_newsletter_yes').radio(value: 'certainly').set
      expect(messages).to eq ["changed: new_user_newsletter", "clicked: new_user_newsletter_yes", "changed: new_user_newsletter"]
    end

    it "doesn't fire onchange event when selecting an already selected radio" do
      browser.radio_set(id: 'new_user_newsletter_yes').radio(value: 'no').set

      browser.radio_set(id: 'new_user_newsletter_yes').radio(value: 'no').set
      expect(messages.size).to eq 1

      browser.radio_set(id: 'new_user_newsletter_yes').radio(value: 'no').set
      expect(messages.size).to eq 1
    end
  end

  describe "eql?" do
    it 'returns true when located by any radio button' do
      rs = browser.radio_set(id: "new_user_newsletter_yes")
      expect(browser.radio_set(id: /new_user_newsletter_yes/)).to eql rs
      expect(browser.radio_set(name: "new_user_newsletter")).to eql rs
      expect(browser.radio_set(name: /new_user_newsletter/)).to eql rs
      expect(browser.radio_set(value: "yes")).to eql rs
      expect(browser.radio_set(value: /yes/)).to eql rs
      expect(browser.radio_set(class: "huge")).to eql rs
      expect(browser.radio_set(class: /huge/)).to eql rs
      expect(browser.radio_set(index: 0)).to eql rs
      expect(browser.radio_set(xpath: "//input[@id='new_user_newsletter_yes']")).to eql rs
    end
  end

  it "returns the text of the selected radio" do
    expect(browser.radio_set(id: 'new_user_newsletter_yes').select("No")).to eq "No"
  end

  it "raises UnknownObjectException if the radio doesn't exist" do
    expect {browser.radio_set(id: 'new_user_newsletter_yes').select("missing_option")}.to raise_unknown_object_exception
    expect {browser.radio_set(id: 'new_user_newsletter_yes').select(/missing_option/)}.to raise_unknown_object_exception
  end

  it "raises ObjectDisabledException if the option is disabled" do
    expect {browser.radio_set(id: 'new_user_newsletter_none').select("None")}.to raise_object_disabled_exception
  end

  it "raises a TypeError if argument is not a String, Regexp or Numeric" do
    expect {browser.radio_set(id: 'new_user_newsletter_yes').select([])}.to raise_error(TypeError)
  end

end
