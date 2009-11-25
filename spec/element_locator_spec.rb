# encoding: utf-8
require "#{File.dirname(__FILE__)}/spec_helper"

describe Watir::ElementLocator do
  def setup(selector)
    driver  = mock("Driver")
    locator = Watir::ElementLocator.new(driver, selector)

    [driver, locator]
  end
end
