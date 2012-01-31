# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "TableHeaders" do
  before :each do
    browser.goto(WatirSpec.url_for("tables.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.theads(:id => "tax_headers").to_a.should == [browser.thead(:id => "tax_headers")]
      end
    end
  end
  
  describe "#length" do
    it "returns the correct number of table theads (page context)" do
      browser.theads.length.should == 1
    end

    it "returns the correct number of table theads (table context)" do
      browser.table(:index, 0).theads.length.should == 1
    end
  end

  describe "#[]" do
    it "returns the row at the given index (page context)" do
      browser.theads[0].id.should == "tax_headers"
    end

    it "returns the row at the given index (table context)" do
      browser.table(:index, 0).theads[0].id.should == "tax_headers"
    end
  end

  describe "#each" do
    it "iterates through table theads correctly (page context)" do
      browser.theads.each_with_index do |thead, index|
        thead.id.should == browser.thead(:index, index).id
      end
    end

    describe "#each" do
      it "iterates through table theads correctly (page context)" do
        count = 0

        browser.theads.each_with_index do |thead, index|
          thead.id.should == browser.thead(:index, index).id

          count += 1
        end

        count.should > 0
      end

      it "iterates through table theads correctly (table context)" do
        table = browser.table(:index, 0)
        count = 0

        table.theads.each_with_index do |thead, index|
          thead.id.should == table.thead(:index, index).id

          count += 1
        end

        count.should > 0
      end
    end
  end
end
