require File.expand_path("../spec_helper", __FILE__)

describe "Element" do
  context "drag and drop" do
    before { browser.goto WatirSpec.url_for("drag_and_drop.html") }

    let(:draggable) { browser.div :id => "draggable" }
    let(:droppable) { browser.div :id => "droppable" }

    not_compliant_on [:webdriver, :iphone] do
      it "can drag and drop an element onto another" do
        droppable.text.should == 'Drop here'
        draggable.drag_and_drop_on droppable
        droppable.text.should == 'Dropped!'
      end
      
      bug "http://code.google.com/p/selenium/issues/detail?id=3075", [:webdriver, :firefox] do
        it "can drag and drop an element onto another when draggable is out of viewport" do
          reposition "draggable"
          perform_drag_and_drop_on_droppable
        end
      end

      it "can drag and drop an element onto another when droppable is out of viewport" do
        reposition "droppable"
        perform_drag_and_drop_on_droppable
      end

      it "can drag an element by the given offset" do
        droppable.text.should == 'Drop here'
        draggable.drag_and_drop_by 200, 50
        droppable.text.should == 'Dropped!'
      end

      def reposition(what)
        browser.button(:id => "reposition#{what.capitalize}").click
      end

      def perform_drag_and_drop_on_droppable
        droppable.text.should == "Drop here"
        draggable.drag_and_drop_on droppable
        droppable.text.should == 'Dropped!'
      end
    end

  end
end
