require 'watirspec_helper'

describe 'TextArea' do
  before :each do
    browser.goto WatirSpec.url_for('forms_with_input_elements.html')
  end

  let(:textarea) { browser.textarea }

  it 'can set a value' do
    textarea.set 'foo'
    expect(textarea.value).to eq 'foo'
  end

  it 'can clear a value' do
    textarea.set 'foo'
    textarea.clear
    expect(textarea.value).to eq ''
  end

  it 'locates textarea by value' do
    browser.textarea.set 'foo'
    expect(browser.textarea(value: /foo/)).to exist
    expect(browser.textarea(value: 'foo')).to exist
  end
end
