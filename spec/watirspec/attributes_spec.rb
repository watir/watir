require "watirspec_helper"

describe "Attributes" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

    it "finds tab index with underscore" do
      expect(browser.checkbox(tab_index: "6").tabindex).to eq 6
    end

  it "finds tab index with downcase" do
    expect(browser.checkbox(tabindex: "4").tab_index).to eq 4
  end

  it "finds element with boolean" do
    expect(browser.checkbox(tab_index: false).id).to eq 'toggle_button_checkbox'
    expect(browser.checkbox(tabindex: true).id).to eq 'new_user_interests_books'
  end
end
