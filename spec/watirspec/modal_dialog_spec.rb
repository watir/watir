# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Modal Dialog" do

  not_compliant_on :webdriver do
    before :each do
      browser.goto(WatirSpec.url_for("modal_dialog.html"))
      browser.button(:value, 'Launch Dialog').click_no_wait
      @modal = browser.modal_dialog
      # make sure that modal dialog exists
      @modal.locate
    end

    after :each do
      @modal.close
    end

    describe "#exists?" do
      it "returns true if modal dialog exists" do
        expect(@modal).to exist
      end

      it "returns false if modal dialog doesn't exist" do
        @modal.close
        expect(@modal).to_not exist
      end
    end

    it "#title" do
      expect(@modal.title).to eq 'Forms with input elements'
    end

    it "allows to access elements within" do
      expect(@modal.select_list(:id, 'new_user_country')).to exist
      expect(@modal.text_field(:id, 'new_user_email')).to exist
      expect(@modal.radio(:id, 'new_user_newsletter_no')).to exist
      expect(@modal.checkbox(:id, 'new_user_interests_cars')).to exist
    end
  end

end

