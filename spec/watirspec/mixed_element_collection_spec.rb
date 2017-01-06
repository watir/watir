require "watirspec_helper"

describe "Mixed Element Collection" do
  before(:all) do
    browser.goto(WatirSpec.url_for("nested_elements.html"))
  end

  describe "#new" do
    it "returns MixedElementCollection when tag name is not specified" do
      expect(browser.div(id: "second_sibling").following_siblings).to be_a Watir::MixedElementCollection
    end

    it "is lazy loaded" do
      element = browser.div(id: "second_sibling")
      allow(element).to receive(:assert_exists).and_raise(Watir::Exception::Error)
      expect { element.following_siblings }.to_not raise_error
    end
  end

  describe "#to_a" do
    it "returns specific element types when evaluated" do
      elements = browser.div(id: "second_sibling").following_siblings
      expect(elements.first).to be_a Watir::Span
      expect(elements.last).to be_a Watir::Div
    end
  end

  describe "#+" do
    it "combines two MixedElementCollections" do
      expect(browser.div(id: "second_sibling").siblings.size).to eq 4
    end

    it "combines MixedElementCollection with non mixed Collection" do
      element = browser.div(id: "second_sibling")
      previous_siblings = element.previous_siblings
      following_siblings = element.following_siblings(tag_name: :div)
      siblings = previous_siblings + following_siblings

      expect(previous_siblings).to be_a Watir::MixedElementCollection
      expect(following_siblings).to be_a Watir::DivCollection
      expect(siblings).to be_a Watir::MixedElementCollection
      expect(siblings.size).to eq 3
    end

    it "combines non mixed Collection with MixedElementCollection" do
      element = browser.div(id: "second_sibling")
      previous_siblings = element.previous_siblings
      following_siblings = element.following_siblings(tag_name: :div)
      siblings = following_siblings + previous_siblings

      expect(previous_siblings).to be_a Watir::MixedElementCollection
      expect(following_siblings).to be_a Watir::DivCollection
      expect(siblings).to be_a Watir::MixedElementCollection
      expect(siblings.size).to eq 3
    end
  end

  describe "#children" do
    it "gets collection of children of an element by default" do
      expect(browser.div(id: "parent").children).to be_a Watir::MixedElementCollection
      expect(browser.div(id: "parent").children.size).to eq 5
    end

    it "accepts tag_name argument" do
      children = browser.div(id: "parent").children(tag_name: :div)
      expect(children.size).to eq 3
      expect(children.all? { |child| child.is_a? Watir::Div }).to eq true
    end
  end
end