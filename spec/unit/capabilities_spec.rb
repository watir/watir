require_relative 'unit_helper'

describe Watir::Capabilities do
  describe '#ie' do
    it 'processes options' do
      options = {browser_attach_timeout: 1, full_page_screenshot: true}
      caps = Watir::Capabilities.new(:ie, options: options)
      opts = caps.to_args.last[:options]
      expect(opts.browser_attach_timeout).to eq 1
      expect(opts.full_page_screenshot).to be true
    end

    it 'processes args' do
      caps = Watir::Capabilities.new(:ie, args: %w[foo bar])
      opts = caps.to_args.last[:options]
      expect(opts.args).to eq Set.new(%w[foo bar])
    end

    it 'processes options class' do
      options = Selenium::WebDriver::IE::Options.new(browser_attach_timeout: 1, full_page_screenshot: true)
      caps = Watir::Capabilities.new(:ie, options: options)
      opts = caps.to_args.last[:options]
      expect(opts.browser_attach_timeout).to eq 1
      expect(opts.full_page_screenshot).to be true
    end
  end
end
