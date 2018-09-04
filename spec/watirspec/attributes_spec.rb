require 'watirspec_helper'

describe 'Attributes' do
  before :each do
    browser.goto(WatirSpec.url_for('forms_with_input_elements.html'))
  end

  it 'finds tab index' do
    expect(browser.checkbox(tabindex: '4').tabindex).to eq 4
  end

  it 'finds element with boolean' do
    expect(browser.checkbox(tabindex: false).id).to eq 'toggle_button_checkbox'
    expect(browser.checkbox(tabindex: true).id).to eq 'new_user_interests_books'
  end
end
