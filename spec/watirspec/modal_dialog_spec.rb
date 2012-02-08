# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Modal Dialog" do

  not_compliant_on :webdriver do
    before :each do
      browser.goto(WatirSpec.url_for("modal_dialog.html"))
      browser.wait
      browser.button(:value, 'Launch Dialog').click_no_wait
      @modal = browser.modal_dialog
    end

    after :each do
      @modal.close if @modal.exists?
      browser.wait
    end

    describe "#exists?" do
      it "after opening" do
        @modal.exists?.should be_true
      end

      it "after closing" do
        @modal.close
        browser.wait
        @modal.exists?.should be_false
      end
    end

    describe "#title" do
      it "attaches to a modal dialog" do
        @modal.title.should == 'Forms with input elements'
      end
    end

    describe "input elements" do
      it "select_list" do
        @modal.select_list(:id, 'new_user_country').select 'Denmark'
      end

      it "text_field" do
        @modal.text_field(:id, 'new_user_email').value = 'foo@bar.com'
      end

      it "radio" do
        @modal.radio(:id, 'new_user_newsletter_no').set
      end

      it "checkbox" do
        @modal.checkbox(:id, 'new_user_interests_cars').set
      end
    end
  end

end