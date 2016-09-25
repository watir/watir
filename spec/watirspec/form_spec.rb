# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Form" do

  before :each do
   browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  describe "#exists?" do
    it "returns true if the form exists" do
      expect(browser.form(id: 'new_user')).to exist
      expect(browser.form(id: /new_user/)).to exist

      expect(browser.form(class: 'user')).to exist
      expect(browser.form(class: /user/)).to exist

      expect(browser.form(method: 'post')).to exist
      expect(browser.form(method: /post/)).to exist
      expect(browser.form(action: /to_me/)).to exist
      expect(browser.form(index: 0)).to exist
      expect(browser.form(xpath: "//form[@id='new_user']")).to exist
    end

    it "returns the first form if given no args" do
      expect(browser.form).to exist
    end

    it "returns false if the form doesn't exist" do
      expect(browser.form(id: 'no_such_id')).to_not exist
      expect(browser.form(id: /no_such_id/)).to_not exist

      expect(browser.form(class: 'no_such_class')).to_not exist
      expect(browser.form(class: /no_such_class/)).to_not exist

      expect(browser.form(method: 'no_such_method')).to_not exist
      expect(browser.form(method: /no_such_method/)).to_not exist
      expect(browser.form(action: 'no_such_action')).to_not exist
      expect(browser.form(action: /no_such_action/)).to_not exist
      expect(browser.form(index: 1337)).to_not exist
      expect(browser.form(xpath: "//form[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.form(id: 3.14).exists? }.to raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      expect { browser.form(no_such_how: 'some_value').exists? }.to raise_error(Watir::Exception::MissingWayOfFindingObjectException)
    end
  end

  bug "https://bugzilla.mozilla.org/show_bug.cgi?id=1290985", :firefox do
    describe "#submit" do
      it "submits the form" do
        browser.form(id: "delete_user").submit
        Watir::Wait.until { !browser.url.include? 'forms_with_input_elements.html' }
        expect(browser.text).to include("Semantic table")
      end

      it "triggers onsubmit event and takes its result into account" do
        form = browser.form(name: "user_new")
        form.submit
        expect(form).to exist
        expect(messages.size).to eq 1
        expect(messages[0]).to eq "submit"
      end
    end
  end

end
