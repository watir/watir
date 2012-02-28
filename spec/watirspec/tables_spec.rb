# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Tables" do

  before :each do
    browser.goto(WatirSpec.url_for("tables.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        browser.tables(:rules => "groups").to_a.should == [browser.table(:rules => "groups")]
      end
    end
  end
  
  describe "#length" do
    it "returns the number of tables" do
      browser.tables.length.should == 4
    end
  end

  describe "#[]" do
    it "returns the p at the given index" do
      browser.tables[0].id.should == "axis_example"
      browser.tables[1].id.should == "outer"
      browser.tables[2].id.should == "inner"
    end
  end

  describe "#each" do
    it "iterates through tables correctly" do
      count = 0

      browser.tables.each_with_index do |t, index|
        t.id.should == browser.table(:index, index).id
        count += 1
      end

      count.should > 0
    end
  end

end
