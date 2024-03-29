# frozen_string_literal: true

require 'watirspec_helper'

module Watir
  describe Anchor do
    before do
      browser.goto(WatirSpec.url_for('non_control_elements.html'))
    end

    # Exists method
    describe '#exist?' do
      it 'returns true if the link exists' do
        expect(browser.link(id: 'link_2')).to exist
        expect(browser.link(id: /link_2/)).to exist
        expect(browser.link(title: 'link_title_2')).to exist
        expect(browser.link(title: /link_title_2/)).to exist
        expect(browser.link(text: 'Link 2')).to exist
        expect(browser.link(text: /Link 2/i)).to exist
        expect(browser.link(href: 'non_control_elements.html')).to exist
        expect(browser.link(href: /non_control_elements.html/)).to exist
        expect(browser.link(index: 1)).to exist
        expect(browser.link(xpath: "//a[@id='link_2']")).to exist
      end

      it 'returns the first link if given no args' do
        expect(browser.link).to exist
      end

      it 'strips spaces from href attribute when locating elements' do
        expect(browser.link(href: /strip_space$/)).to exist
      end

      it "returns false if the link doesn't exist" do
        expect(browser.link(id: 'no_such_id')).not_to exist
        expect(browser.link(id: /no_such_id/)).not_to exist
        expect(browser.link(title: 'no_such_title')).not_to exist
        expect(browser.link(title: /no_such_title/)).not_to exist
        expect(browser.link(text: 'no_such_text')).not_to exist
        expect(browser.link(text: /no_such_text/i)).not_to exist
        expect(browser.link(href: 'no_such_href')).not_to exist
        expect(browser.link(href: /no_such_href/)).not_to exist
        expect(browser.link(index: 1337)).not_to exist
        expect(browser.link(xpath: "//a[@id='no_such_id']")).not_to exist
      end

      it "raises TypeError when 'what' argument is invalid" do
        expect { browser.link(id: 3.14).exists? }.to raise_error(TypeError)
      end
    end

    # Attribute methods
    describe '#href' do
      it 'returns the href attribute if the link exists' do
        expect(browser.link(index: 1).href).to match(/non_control_elements/)
      end

      it "returns an empty string if the link exists and the attribute doesn't" do
        expect(browser.link(index: 0).href).to eq ''
      end

      it "raises an UnknownObjectException if the link doesn't exist" do
        expect { browser.link(index: 1337).href }.to raise_unknown_object_exception
      end
    end

    describe '#id' do
      it 'returns the id attribute if the link exists' do
        expect(browser.link(index: 1).id).to eq 'link_2'
      end

      it "returns an empty string if the link exists and the attribute doesn't" do
        expect(browser.link(index: 0).id).to eq ''
      end

      it "raises an UnknownObjectException if the link doesn't exist" do
        expect { browser.link(index: 1337).id }.to raise_unknown_object_exception
      end
    end

    describe '#text' do
      it 'returns the link text' do
        expect(browser.link(index: 1).text).to eq 'Link 2'
      end

      it 'returns an empty string if the link exists and contains no text' do
        expect(browser.link(index: 0).text).to eq ''
      end

      it "raises an UnknownObjectException if the link doesn't exist" do
        expect { browser.link(index: 1337).text }.to raise_unknown_object_exception
      end
    end

    describe '#title' do
      it 'returns the type attribute if the link exists' do
        expect(browser.link(index: 1).title).to eq 'link_title_2'
      end

      it "returns an empty string if the link exists and the attribute doesn't" do
        expect(browser.link(index: 0).title).to eq ''
      end

      it "raises an UnknownObjectException if the link doesn't exist" do
        expect { browser.link(index: 1337).title }.to raise_unknown_object_exception
      end
    end

    describe '#respond_to?' do
      it 'returns true for all attribute methods' do
        expect(browser.link(index: 0)).to respond_to(:class_name)
        expect(browser.link(index: 0)).to respond_to(:href)
        expect(browser.link(index: 0)).to respond_to(:id)
        expect(browser.link(index: 0)).to respond_to(:style)
        expect(browser.link(index: 0)).to respond_to(:text)
        expect(browser.link(index: 0)).to respond_to(:title)
      end
    end

    # Manipulation methods
    # Note: the #wait_until calls are hacks for Safari specifically
    describe '#click' do
      it 'finds an existing link by (text: String) and clicks it' do
        element = browser.link(text: 'Link 3')
        element.wait_until { |link| !link.exist? || link.click }
        expect(browser.h1(text: 'User administration')).to exist
      end

      it 'finds an existing link by (text: Regexp) and clicks it' do
        element = browser.link(href: /forms_with_input_elements/)
        element.wait_until { |link| !link.exist? || link.click }
        expect(browser.h1(text: 'User administration')).to exist
      end

      it 'finds an existing link by (index: Integer) and clicks it' do
        element = browser.link(index: 2)
        element.wait_until { |link| !link.exist? || link.click }
        expect(browser.h1(text: 'User administration')).to exist
      end

      it "raises an UnknownObjectException if the link doesn't exist" do
        expect { browser.link(index: 1337).click }.to raise_unknown_object_exception
      end

      it 'clicks a link with no text content but an img child' do
        browser.goto WatirSpec.url_for('images.html')
        browser.link(href: /definition_lists.html/).click
        browser.wait_while(title: /^(Images|)$/)
        expect(browser.title).to eq 'definition_lists'
      end
    end

    describe 'visible text' do
      it 'finds links by visible text' do
        browser.goto WatirSpec.url_for('non_control_elements.html')

        expect(browser.link(visible_text: 'all visible')).to exist
        expect(browser.link(visible_text: /all visible/)).to exist
        expect(browser.link(visible_text: /some visible/)).to exist

        expect(browser.link(visible_text: 'Link 2', class: 'external')).to exist
        expect(browser.link(visible_text: /Link 2/, class: 'external')).to exist
      end

      it 'finds links in spite of hidden text' do
        browser.goto WatirSpec.url_for('non_control_elements.html')

        expect(browser.link(visible_text: 'some visible')).to exist
        expect(browser.link(visible_text: 'none visible')).not_to exist
        expect(browser.link(visible_text: /none visible/)).not_to exist
      end

      it 'raises exception unless value is a String or a RegExp' do
        browser.goto WatirSpec.url_for('non_control_elements.html')
        msg = /expected one of \[String, Regexp\], got 7:Integer/
        expect { browser.link(visible_text: 7).exists? }.to raise_exception(TypeError, msg)
      end
    end
  end
end
