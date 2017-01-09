require "watirspec_helper"

describe "Adjacent Elements" do
  before(:all) do
    browser.goto(WatirSpec.url_for("nested_elements.html"))
  end

  describe "#parent" do
    it "gets immediate parent of an element by default" do
      expect(browser.div(id: "first_sibling").parent.id).to eq 'parent'
      expect(browser.div(id: "first_sibling").parent).to be_a Watir::HTMLElement
    end

    it "accepts index argument" do
      expect(browser.div(id: "first_sibling").parent(index: 2).id).to eq 'grandparent'
      expect(browser.div(id: "first_sibling").parent(index: 2)).to be_a Watir::HTMLElement
    end

    it "accepts tag_name argument" do
      expect(browser.div(id: "first_sibling").parent(tag_name: :div).id).to eq 'parent'
      expect(browser.div(id: "first_sibling").parent(tag_name: :div)).to be_a Watir::Div
    end

    it "accepts index and tag_name arguments" do
      expect(browser.div(id: "first_sibling").parent(tag_name: :div, index: 1).id).to eq 'grandparent'
      expect(browser.div(id: "first_sibling").parent(tag_name: :div, index: 1)).to be_a Watir::Div
    end

    it "does not error when no parent element of an index exists" do
      expect(browser.body.parent(index: 2)).to_not exist
    end

    it "does not error when no parent element of a tag_name exists" do
      expect(browser.div(id: "first_sibling").parent(tag_name: :table)).to_not exist
    end
  end

  describe "#following_sibling" do
    it "gets immediate following sibling of an element by default" do
      expect(browser.div(id: "first_sibling").following_sibling.id).to eq 'between_siblings1'
      expect(browser.div(id: "first_sibling").following_sibling).to be_a Watir::HTMLElement
    end

    it "accepts index argument" do
      expect(browser.div(id: "first_sibling").following_sibling(index: 2).id).to eq 'between_siblings2'
      expect(browser.div(id: "first_sibling").following_sibling(index: 2)).to be_a Watir::HTMLElement
    end

    it "accepts tag_name argument" do
      expect(browser.div(id: "first_sibling").following_sibling(tag_name: :div).id).to eq 'second_sibling'
      expect(browser.div(id: "first_sibling").following_sibling(tag_name: :div)).to be_a Watir::Div
    end

    it "accepts index and tag_name arguments" do
      expect(browser.div(id: "first_sibling").following_sibling(tag_name: :div, index: 1).id).to eq 'third_sibling'
      expect(browser.div(id: "first_sibling").following_sibling(tag_name: :div, index: 1)).to be_a Watir::Div
    end

    it "does not error when no next sibling of an index exists" do
      expect(browser.body.following_sibling(index: 1)).to_not exist
    end

    it "does not error when no next sibling of a tag_name exists" do
      expect(browser.div(id: "first_sibling").following_sibling(tag_name: :table)).to_not exist
    end
  end

  describe "#following_siblings" do
    it "gets collection of subsequent siblings of an element by default" do
      expect(browser.div(id: "second_sibling").following_siblings).to be_a Watir::HTMLElementCollection
      expect(browser.div(id: "second_sibling").following_siblings.size).to eq 2
    end

    it "accepts tag_name argument" do
      expect(browser.div(id: "second_sibling").following_siblings(tag_name: :div).size).to eq 1
      expect(browser.div(id: "second_sibling").following_siblings(tag_name: :div).first).to be_a Watir::Div
    end
  end

  describe "#previous_sibling" do
    it "gets immediate preceeding sibling of an element by default" do
      expect(browser.div(id: "third_sibling").previous_sibling.id).to eq 'between_siblings2'
      expect(browser.div(id: "third_sibling").previous_sibling).to be_a Watir::HTMLElement
    end

    it "accepts index argument" do
      expect(browser.div(id: "third_sibling").previous_sibling(index: 2).id).to eq 'between_siblings1'
      expect(browser.div(id: "third_sibling").previous_sibling(index: 2)).to be_a Watir::HTMLElement
    end

    it "accepts tag_name argument" do
      expect(browser.div(id: "third_sibling").previous_sibling(tag_name: :div).id).to eq 'second_sibling'
      expect(browser.div(id: "third_sibling").previous_sibling(tag_name: :div)).to be_a Watir::Div
    end

    it "accepts index and tag_name arguments" do
      expect(browser.div(id: "third_sibling").previous_sibling(tag_name: :div, index: 1).id).to eq 'first_sibling'
      expect(browser.div(id: "third_sibling").previous_sibling(tag_name: :div, index: 1)).to be_a Watir::Div
    end

    it "does not error when no next sibling of an index exists" do
      expect(browser.body.previous_sibling(index: 1)).to_not exist
    end

    it "does not error when no next sibling of a tag_name exists" do
      expect(browser.div(id: "third_sibling").previous_sibling(tag_name: :table)).to_not exist
    end
  end

  describe "#previous_siblings" do
    it "gets collection of previous siblings of an element by default" do
      expect(browser.div(id: "second_sibling").previous_siblings).to be_a Watir::HTMLElementCollection
      expect(browser.div(id: "second_sibling").previous_siblings.size).to eq 2
    end

    it "accepts tag_name argument" do
      expect(browser.div(id: "second_sibling").previous_siblings(tag_name: :div).size).to eq 1
      expect(browser.div(id: "second_sibling").previous_siblings(tag_name: :div).first).to be_a Watir::Div
    end
  end

  describe "#siblings" do
    it "gets collection of siblings of an element" do
      expect(browser.div(id: "first_sibling").siblings.size).to eq 4
    end

    it "gets collection of siblings of an element by tag" do
      siblings = browser.div(id: "first_sibling").siblings(tag_name: :div)
      expect(siblings.size).to eq 2
      expect(siblings.all? { |sib| sib.is_a? Watir::Div }).to eq true
    end
  end

  describe "#child" do
    it "gets immediate child of an element by default" do
      expect(browser.div(id: "parent").child.id).to eq 'first_sibling'
      expect(browser.div(id: "parent").child).to be_a Watir::HTMLElement
    end

    it "accepts index argument" do
      expect(browser.div(id: "parent").child(index: 2).id).to eq 'second_sibling'
      expect(browser.div(id: "parent").child(index: 2)).to be_a Watir::HTMLElement
    end

    it "accepts tag_name argument" do
      expect(browser.div(id: "parent").child(tag_name: :span).id).to eq 'between_siblings1'
      expect(browser.div(id: "parent").child(tag_name: :span)).to be_a Watir::Span
    end

    it "accepts index and tag_name arguments" do
      expect(browser.div(id: "parent").child(tag_name: :div, index: 1).id).to eq 'second_sibling'
      expect(browser.div(id: "parent").child(tag_name: :div, index: 1)).to be_a Watir::Div
    end

    it "does not error when no next sibling of an index exists" do
      expect(browser.div(id: "second_sibling").child(index: 1)).to_not exist
    end

    it "does not error when no next sibling of a tag_name exists" do
      expect(browser.div(id: "parent").child(tag_name: :table)).to_not exist
    end
  end

  describe "#children" do
    it "gets collection of children of an element by default" do
      expect(browser.div(id: "parent").children).to be_a Watir::HTMLElementCollection
      expect(browser.div(id: "parent").children.size).to eq 5
    end

    it "accepts tag_name argument" do
      children = browser.div(id: "parent").children(tag_name: :div)
      expect(children.size).to eq 3
      expect(children.all? { |child| child.is_a? Watir::Div }).to eq true
    end
  end
end