# frozen_string_literal: true

require 'watirspec_helper'

module Watir
  describe Input do
    before do
      browser.goto WatirSpec.url_for('forms_with_input_elements.html')
    end

    describe '#type' do
      it 'returns an email type' do
        expect(browser.input(name: 'html5_email').type).to eq 'email'
      end
    end
  end
end
