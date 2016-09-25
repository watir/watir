# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Option" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  describe "#exists?" do
    it "returns true if the element exists (page context)" do
      expect(browser.option(id: "nor")).to exist
      expect(browser.option(id: /nor/)).to exist
      expect(browser.option(value: "2")).to exist
      expect(browser.option(value: /2/)).to exist
      expect(browser.option(text: "Norway")).to exist
      expect(browser.option(text: /Norway/)).to exist
      expect(browser.option(class: "scandinavia")).to exist
      expect(browser.option(index: 1)).to exist
      expect(browser.option(xpath: "//option[@id='nor']")).to exist
    end

    it "returns the first option if given no args" do
      expect(browser.option).to exist
    end

    it "returns true if the element exists (select_list context)" do
      expect(browser.select_list(name: "new_user_country").option(id: "nor")).to exist
      expect(browser.select_list(name: "new_user_country").option(id: /nor/)).to exist
      expect(browser.select_list(name: "new_user_country").option(value: "2")).to exist
      expect(browser.select_list(name: "new_user_country").option(value: /2/)).to exist
      expect(browser.select_list(name: "new_user_country").option(text: "Norway")).to exist
      expect(browser.select_list(name: "new_user_country").option(text: /Norway/)).to exist
      expect(browser.select_list(name: "new_user_country").option(class: "scandinavia")).to exist
      expect(browser.select_list(name: "new_user_country").option(index: 1)).to exist
      expect(browser.select_list(name: "new_user_country").option(xpath: "//option[@id='nor']")).to exist
      expect(browser.select_list(name: "new_user_country").option(label: "Germany")).to exist
    end

    it "returns false if the element does not exist (page context)" do
      expect(browser.option(id: "no_such_id")).to_not exist
      expect(browser.option(id: /no_such_id/)).to_not exist
      expect(browser.option(value: "no_such_value")).to_not exist
      expect(browser.option(value: /no_such_value/)).to_not exist
      expect(browser.option(text: "no_such_text")).to_not exist
      expect(browser.option(text: /no_such_text/)).to_not exist
      expect(browser.option(class: "no_such_class")).to_not exist
      expect(browser.option(index: 1337)).to_not exist
      expect(browser.option(xpath: "//option[@id='no_such_id']")).to_not exist
    end

    it "returns false if the element does not exist (select_list context)" do
      expect(browser.select_list(name: "new_user_country").option(id: "no_such_id")).to_not exist
      expect(browser.select_list(name: "new_user_country").option(id: /no_such_id/)).to_not exist
      expect(browser.select_list(name: "new_user_country").option(value: "no_such_value")).to_not exist
      expect(browser.select_list(name: "new_user_country").option(value: /no_such_value/)).to_not exist
      expect(browser.select_list(name: "new_user_country").option(text: "no_such_text")).to_not exist
      expect(browser.select_list(name: "new_user_country").option(text: /no_such_text/)).to_not exist
      expect(browser.select_list(name: "new_user_country").option(class: "no_such_class")).to_not exist
      expect(browser.select_list(name: "new_user_country").option(index: 1337)).to_not exist
      expect(browser.select_list(name: "new_user_country").option(xpath: "//option[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.option(id: 3.14).exists? }.to raise_error(TypeError)
      expect { browser.select_list(name: "new_user_country").option(id: 3.14).exists? }.to raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      expect { browser.option(no_such_how: 'some_value').exists? }.to raise_error(Watir::Exception::MissingWayOfFindingObjectException)
      expect { browser.select_list(name: "new_user_country").option(no_such_how: 'some_value').exists? }.to raise_error(Watir::Exception::MissingWayOfFindingObjectException)
    end
  end

  bug "https://bugzilla.mozilla.org/show_bug.cgi?id=1255957", :firefox do
    describe "#select" do
      it "selects the chosen option (page context)" do
        browser.option(text: "Denmark").select
        expect(browser.select_list(name: "new_user_country").selected_options.map(&:text)).to eq ["Denmark"]
      end

      it "selects the chosen option (select_list context)" do
        browser.select_list(name: "new_user_country").option(text: "Denmark").select
        expect(browser.select_list(name: "new_user_country").selected_options.map(&:text)).to eq ["Denmark"]
      end

      it "selects the option when found by text (page context)" do
        browser.option(text: 'Sweden').select
        expect(browser.option(text: 'Sweden')).to be_selected
      end

      it "selects the option when found by text (select_list context)" do
        browser.select_list(name: 'new_user_country').option(text: 'Sweden').select
        expect(browser.select_list(name: 'new_user_country').option(text: 'Sweden')).to be_selected
      end

      # there's no onclick event for Option in IE / WebKit
      # http://msdn.microsoft.com/en-us/library/ms535877(VS.85).aspx
      compliant_on :ff_legacy do
        it "fires the onclick event (page context)" do
          browser.option(text: "Username 3").select
          expect(browser.textarea(id: 'delete_user_comment').value).to eq 'Don\'t do it!'
        end
      end
    end

    # there's no onclick event for Option in IE / WebKit
    # http://msdn.microsoft.com/en-us/library/ms535877(VS.85).aspx
    compliant_on :ff_legacy do
      it "fires onclick event (select_list context)" do
        browser.select_list(id: 'delete_user_username').option(text: "Username 3").select
        expect(browser.textarea(id: 'delete_user_comment').value).to eq 'Don\'t do it!'
      end
    end

    it "raises UnknownObjectException if the option does not exist (page context)" do
      expect { browser.option(text: "no_such_text").select }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.option(text: /missing/).select }.to raise_error(Watir::Exception::UnknownObjectException)
    end

    it "raises UnknownObjectException if the option does not exist (select_list context)" do
      expect { browser.select_list(name: "new_user_country").option(text: "no_such_text").select }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.select_list(name: "new_user_country").option(text: /missing/).select }.to raise_error(Watir::Exception::UnknownObjectException)
    end

    it "raises MissingWayOfFindingObjectException when given a bad 'how' (page context)" do
      expect { browser.option(missing: "Denmark").select }.to raise_error(Watir::Exception::MissingWayOfFindingObjectException)
    end

    it "raises MissingWayOfFindingObjectException when given a bad 'how' (select_list context)" do
      expect { browser.select_list(name: "new_user_country").option(missing: "Denmark").select }.to raise_error(Watir::Exception::MissingWayOfFindingObjectException)
    end
  end

  describe "#class_name" do
    it "is able to get attributes (page context)" do
      expect(browser.option(text: 'Sweden').class_name).to eq "scandinavia"
    end

    it "is able to get attributes (select_list context)" do
      expect(browser.select_list(name: "new_user_country").option(text: 'Sweden').class_name).to eq "scandinavia"
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      expect(browser.select_list(name: "new_user_country").option(text: 'Sweden')).to respond_to(:class_name)
      expect(browser.select_list(name: "new_user_country").option(text: 'Sweden')).to respond_to(:id)
      expect(browser.select_list(name: "new_user_country").option(text: 'Sweden')).to respond_to(:text)
    end
  end

end
