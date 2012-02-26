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
        @modal.should exist
      end

      it "returns false if modal dialog doesn't exist" do
        @modal.close
        @modal.should_not exist
      end
    end

    it "#title" do
      @modal.title.should == 'Forms with input elements'
    end

    it "allows to access elements within" do
      @modal.select_list(:id, 'new_user_country').should exist
      @modal.text_field(:id, 'new_user_email').should exist
      @modal.radio(:id, 'new_user_newsletter_no').should exist
      @modal.checkbox(:id, 'new_user_interests_cars').should exist
    end
  end

end

