require File.expand_path("../spec_helper", __FILE__)

describe "TextArea" do
  before :each do
    browser.goto WatirSpec.url_for('forms_with_input_elements.html')
  end

  let(:textarea) { browser.textarea }

  it 'can set a value' do
    textarea.set 'foo'
    textarea.value.should == 'foo'
  end

  it 'can clear a value' do
    textarea.set 'foo'
    textarea.clear
    textarea.value.should == ''
  end

end
