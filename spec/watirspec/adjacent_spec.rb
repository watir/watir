require 'watirspec_helper'

describe 'Adjacent Elements' do
  before(:all) do
    browser.goto(WatirSpec.url_for('nested_elements.html'))
  end

  describe '#parent' do
    it 'gets immediate parent of an element by default' do
      expect(browser.div(id: 'first_sibling').parent.id).to eq 'parent'
      expect(browser.div(id: 'first_sibling').parent).to be_a Watir::HTMLElement
    end

    it 'accepts index argument' do
      expect(browser.div(id: 'first_sibling').parent(index: 2).id).to eq 'grandparent'
      expect(browser.div(id: 'first_sibling').parent(index: 2)).to be_a Watir::HTMLElement
    end

    it 'accepts tag_name argument' do
      expect(browser.div(id: 'first_sibling').parent(tag_name: 'div').id).to eq 'parent'
      expect(browser.div(id: 'first_sibling').parent(tag_name: 'div')).to be_a Watir::Div
    end

    it 'accepts custom tag_name argument' do
      expect(browser.div(id: 'regular_child').parent(tag_name: 'grandelement').id).to eq 'custom_grandparent'
      expect(browser.div(id: 'regular_child').parent(tag_name: 'grandelement')).to be_a Watir::HTMLElement
    end

    it 'accepts class_name argument' do
      expect(browser.div(id: 'first_sibling').parent(class_name: 'parent').id).to eq 'parent_span'
    end

    it 'accepts index and tag_name arguments' do
      expect(browser.div(id: 'first_sibling').parent(tag_name: 'div', index: 1).id).to eq 'grandparent'
      expect(browser.div(id: 'first_sibling').parent(tag_name: 'div', index: 1)).to be_a Watir::Div
    end

    it 'does not error when no parent element of an index exists' do
      expect(browser.body.parent(index: 2)).to_not exist
    end

    it 'does not error when no parent element of a tag_name exists' do
      expect(browser.div(id: 'first_sibling').parent(tag_name: 'table')).to_not exist
    end
  end

  describe '#siblings' do
    it 'gets collection of all siblings of an element' do
      expect(browser.div(id: 'second_sibling').siblings).to be_a Watir::HTMLElementCollection
      expect(browser.div(id: 'second_sibling').siblings.size).to eq 5
    end

    it 'accepts a tag name argument' do
      siblings = browser.div(id: 'second_sibling').siblings(tag_name: 'div')
      expect(siblings.size).to eq 3
      expect(siblings.all? { |sib| sib.is_a? Watir::Div }).to eq true
    end

    it 'accepts custom tag name argument' do
      siblings = browser.div(id: 'regular_child').siblings(tag_name: 'childelement')
      expect(siblings.size).to eq 3
      expect(siblings.all? { |sib| sib.is_a? Watir::HTMLElement }).to eq true
    end

    it 'accepts a class_name argument' do
      siblings = browser.div(id: 'second_sibling').siblings(class_name: 'b')
      expect(siblings.first).to be_a Watir::Div
      expect(siblings[0]).to be_a Watir::Div
      expect(siblings.size).to eq 2
      expect(siblings.all? { |sib| sib.is_a? Watir::Div }).to eq true
    end
  end

  describe '#following_sibling' do
    it 'gets immediate following sibling of an element by default' do
      expect(browser.div(id: 'first_sibling').following_sibling.id).to eq 'between_siblings1'
      expect(browser.div(id: 'first_sibling').following_sibling).to be_a Watir::HTMLElement
    end

    it 'accepts index argument' do
      expect(browser.div(id: 'first_sibling').following_sibling(index: 2).id).to eq 'between_siblings2'
      expect(browser.div(id: 'first_sibling').following_sibling(index: 2)).to be_a Watir::HTMLElement
    end

    it 'accepts tag_name argument' do
      expect(browser.div(id: 'first_sibling').following_sibling(tag_name: 'div').id).to eq 'second_sibling'
      expect(browser.div(id: 'first_sibling').following_sibling(tag_name: 'div')).to be_a Watir::Div
    end

    it 'accepts class_name argument' do
      expect(browser.div(id: 'first_sibling').following_sibling(class_name: 'b').id).to eq 'second_sibling'
    end

    it 'accepts index and tag_name arguments' do
      expect(browser.div(id: 'first_sibling').following_sibling(tag_name: 'div', index: 1).id).to eq 'third_sibling'
      expect(browser.div(id: 'first_sibling').following_sibling(tag_name: 'div', index: 1)).to be_a Watir::Div
    end

    it 'accepts text as Regexp' do
      expect(browser.div(id: 'first_sibling').following_sibling(text: /T/).id).to eq 'third_sibling'
    end

    it 'accepts text as String' do
      expect(browser.div(id: 'first_sibling').following_sibling(text: 'Third').id).to eq 'third_sibling'
    end

    it 'does not error when no next sibling of an index exists' do
      expect(browser.body.following_sibling(index: 1)).to_not exist
    end

    it 'does not error when no next sibling of a tag_name exists' do
      expect(browser.div(id: 'first_sibling').following_sibling(tag_name: 'table')).to_not exist
    end
  end

  describe '#following_siblings' do
    it 'gets collection of subsequent siblings of an element by default' do
      expect(browser.div(id: 'second_sibling').following_siblings).to be_a Watir::HTMLElementCollection
      expect(browser.div(id: 'second_sibling').following_siblings.size).to eq 2
    end

    it 'accepts tag_name argument' do
      expect(browser.div(id: 'second_sibling').following_siblings(tag_name: 'div').size).to eq 1
      expect(browser.div(id: 'second_sibling').following_siblings(tag_name: 'div').first).to be_a Watir::Div
    end

    it 'accepts class_name argument for single class' do
      expect(browser.div(id: 'second_sibling').following_siblings(class_name: 'b').size).to eq 1
      expect(browser.div(id: 'second_sibling').following_siblings(class_name: 'b').first).to be_a Watir::Div
    end

    it 'accepts class_name argument for multiple classes' do
      expect(browser.div(id: 'second_sibling').following_siblings(class_name: %w[a b]).size).to eq 1
      expect(browser.div(id: 'second_sibling').following_siblings(class_name: %w[a b]).first).to be_a Watir::Div
    end
  end

  describe '#previous_sibling' do
    it 'gets immediate preceeding sibling of an element by default' do
      expect(browser.div(id: 'third_sibling').previous_sibling.id).to eq 'between_siblings2'
      expect(browser.div(id: 'third_sibling').previous_sibling).to be_a Watir::HTMLElement
    end

    it 'accepts index argument' do
      expect(browser.div(id: 'third_sibling').previous_sibling(index: 2).id).to eq 'between_siblings1'
      expect(browser.div(id: 'third_sibling').previous_sibling(index: 2)).to be_a Watir::HTMLElement
    end

    it 'accepts tag_name argument' do
      expect(browser.div(id: 'third_sibling').previous_sibling(tag_name: 'div').id).to eq 'second_sibling'
      expect(browser.div(id: 'third_sibling').previous_sibling(tag_name: 'div')).to be_a Watir::Div
    end

    it 'accepts class_name argument' do
      expect(browser.div(id: 'third_sibling').previous_sibling(class_name: 'a').id).to eq 'between_siblings2'
    end

    it 'accepts index and tag_name arguments' do
      expect(browser.div(id: 'third_sibling').previous_sibling(tag_name: 'div', index: 1).id).to eq 'first_sibling'
      expect(browser.div(id: 'third_sibling').previous_sibling(tag_name: 'div', index: 1)).to be_a Watir::Div
    end

    it 'does not error when no next sibling of an index exists' do
      expect(browser.body.previous_sibling(index: 1)).to_not exist
    end

    it 'does not error when no next sibling of a tag_name exists' do
      expect(browser.div(id: 'third_sibling').previous_sibling(tag_name: 'table')).to_not exist
    end
  end

  describe '#previous_siblings' do
    it 'gets collection of previous siblings of an element by default' do
      expect(browser.div(id: 'second_sibling').previous_siblings).to be_a Watir::HTMLElementCollection
      expect(browser.div(id: 'second_sibling').previous_siblings.size).to eq 2
    end

    it 'accepts tag_name argument' do
      expect(browser.div(id: 'second_sibling').previous_siblings(tag_name: 'div').size).to eq 1
      expect(browser.div(id: 'second_sibling').previous_siblings(tag_name: 'div').first).to be_a Watir::Div
    end

    it 'accepts class_name argument' do
      expect(browser.div(id: 'second_sibling').previous_siblings(class_name: 'a').size).to eq 1
      expect(browser.div(id: 'second_sibling').previous_siblings(class_name: 'a').first.id).to eq 'between_siblings1'
    end
  end

  describe '#child' do
    it 'gets immediate child of an element by default' do
      expect(browser.div(id: 'parent').child.id).to eq 'first_sibling'
      expect(browser.div(id: 'parent').child).to be_a Watir::HTMLElement
    end

    it 'accepts index argument' do
      expect(browser.div(id: 'parent').child(index: 2).id).to eq 'second_sibling'
      expect(browser.div(id: 'parent').child(index: 2)).to be_a Watir::HTMLElement
    end

    it 'accepts tag_name argument' do
      expect(browser.div(id: 'parent').child(tag_name: 'span').id).to eq 'between_siblings1'
      expect(browser.div(id: 'parent').child(tag_name: 'span')).to be_a Watir::Span
    end

    it 'accepts custom tag_name argument' do
      expect(browser.element(id: 'custom_parent').child(tag_name: 'childelement').id).to eq 'custom_child'
      expect(browser.element(id: 'custom_parent').child(tag_name: 'childelement')).to be_a Watir::HTMLElement
    end

    it 'accepts class_name argument' do
      expect(browser.div(id: 'parent').child(class_name: 'b').id).to eq 'second_sibling'
    end

    it 'accepts index and tag_name arguments' do
      expect(browser.div(id: 'parent').child(tag_name: 'div', index: 1).id).to eq 'second_sibling'
      expect(browser.div(id: 'parent').child(tag_name: 'div', index: 1)).to be_a Watir::Div
    end

    it 'does not error when no next sibling of an index exists' do
      expect(browser.div(id: 'second_sibling').child(index: 1)).to_not exist
    end

    it 'does not error when no next sibling of a tag_name exists' do
      expect(browser.div(id: 'parent').child(tag_name: 'table')).to_not exist
    end
  end

  describe '#children' do
    it 'gets collection of children of an element by default' do
      expect(browser.div(id: 'parent').children).to be_a Watir::HTMLElementCollection
      expect(browser.div(id: 'parent').children.size).to eq 5
    end

    it 'accepts tag_name argument' do
      children = browser.div(id: 'parent').children(tag_name: 'div')
      expect(children.size).to eq 3
      expect(children.all? { |child| child.is_a? Watir::Div }).to eq true
    end

    it 'accepts custom tag_name argument' do
      children = browser.element(id: 'custom_parent').children(tag_name: 'childelement')
      expect(children.size).to eq 3
      expect(children.all? { |child| child.is_a? Watir::HTMLElement }).to eq true
    end

    it 'accepts a class_name argument' do
      children = browser.div(id: 'parent').children(class_name: 'b')
      expect(children.size).to eq 2
      expect(children.all? { |child| child.is_a? Watir::Div }).to eq true
    end
  end
end
