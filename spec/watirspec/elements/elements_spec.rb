require "watirspec_helper"

describe "Elements" do
  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  describe "#[]" do
    context "when elements do not exist" do
      it "returns not existing element" do
        expect(browser.elements(id: "non-existing")[0]).not_to exist
      end
    end
  end
end
