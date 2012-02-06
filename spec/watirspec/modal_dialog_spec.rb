# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Modal Dialog" do
  before :each do
    browser.goto(WatirSpec.url_for("modal_dialog.html"))
    browser.button(:value, 'Launch Dialog').click_no_wait
    @modal = browser.modal_dialog(:title, 'Modal Dialog')
  end

  after :each do
    browser.modal_dialog.close if browser.modal_dialog.exists?
    browser.wait
  end

  describe "#exists?" do
    it "after opening" do
      @modal.exists?.should be_true
    end

    it "after closing" do
      @modal.modal_dialog.close
      browser.wait
      @modal.exists?.should be_false
    end
  end

  describe "#title" do
    it "attaches to a modal dialog" do
      @modal.title.should == 'Forms with input elements'
    end
  end

  describe "#hwnd" do
    it "has a different windows handle than the main browser" do
      browser.hwnd.should_not == @modal.hwnd
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