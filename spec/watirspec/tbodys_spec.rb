# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "TableBodies" do

  before :each do
    browser.goto(WatirSpec.url_for("tables.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.tbodys(:id => "first").to_a.should == [browser.tbody(:id => "first")]
      end
    end
  end
  
  describe "#length" do
    it "returns the correct number of table bodies (page context)" do
      browser.tbodys.length.should == 5
    end

    it "returns the correct number of table bodies (table context)" do
      browser.table(:index, 0).tbodys.length.should == 2
    end
  end

  describe "#[]" do
    it "returns the row at the given index (page context)" do
      browser.tbodys[0].id.should == "first"
    end

    it "returns the row at the given index (table context)" do
      browser.table(:index, 0).tbodys[0].id.should == "first"
    end
  end

  describe "#each" do
    it "iterates through table bodies correctly (table context)" do
      count = 0

      browser.tbodys.each_with_index do |body, index|
        body.id.should == browser.tbody(:index, index).id

        count += 1
      end

      count.should > 0
    end

    it "iterates through table bodies correctly (table context)" do
      table = browser.table(:index, 0)
      count = 0

      table.tbodys.each_with_index do |body, index|
        body.id.should == table.tbody(:index, index).id

        count += 1
      end

      count.should > 0
    end
  end

end
