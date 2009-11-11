require "#{File.dirname(__FILE__)}/spec_helper"

describe Watir::ElementLocator do
  def setup(selector)
    driver = mock("Driver")
    locator = Watir::ElementLocator.new(driver, selector)
    
    [driver, locator]
  end

  it "finds the first element by tag name (string)" do
    driver, locator = setup(:tag_name => 'span')
    driver.should_receive(:find_element).with(:tag_name, 'span').and_return 'some-element'
    
    locator.locate.should == 'some-element'
  end
  
  it "finds the first element by tag name (regexp)" do
    driver, locator    = setup(:tag_name => /span/)
    element_collection = mock('element_array')
    element            = mock('element', :tag_name => 'span')
    
    driver.should_receive(:find_elements).with(:xpath, '//*').and_return(element_collection)
    element_collection.should_receive(:find).and_return(element)
    
    locator.locate.should == element
  end
  
  it "finds the first element by class and tag name (string)" do
    driver, locator = setup(:tag_name => 'span', :class => 'date')
    
    # find_element returns an element with the wrong tag name
    driver.should_receive(:find_element).with(:class, 'date').and_return mock(:tag_name => 'div')
    # fall back to iterating over all the elements
    driver.should_receive(:find_elements).with(:class, 'date').and_return [ mock(:tag_name => 'div', :class_name => 'date'), 
                                                                            mock(:tag_name => 'span', :class_name => 'date')]
                                                                            
    result = locator.locate
    result.tag_name.should == 'span'
    result.class_name.should == 'date'
  end
  
end