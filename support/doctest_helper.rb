require 'watir'
require 'watirspec'
require 'webdrivers'

#
# 1. If example does not start browser, start new one, reuse until example
#    finishes and close after.
# 2. If example starts browser and assigns it to local variable `browser`,
#    it will still be closed.
#

def browser
  $browser ||= Watir::Browser.new(:chrome)
end

YARD::Doctest.configure do |doctest|
  doctest.skip 'Watir::Browser.start'
  doctest.skip 'Watir::Cookies'
  doctest.skip 'Watir::Element#to_subtype'
  doctest.skip 'Watir::Option'
  doctest.skip 'Watir::Screenshot'
  doctest.skip 'Watir::Window#size'
  doctest.skip 'Watir::Window#position'
  doctest.skip 'Watir::Window#maximize'

  doctest.before do
    WatirSpec.run!
    sleep 1 # give Chrome some time to breathe in
    browser.goto WatirSpec.url_for('forms_with_input_elements.html')
  end

  doctest.after do
    sleep 1 # give Chrome some time to breathe out
    browser.windows.drop(1).each(&:close)
  end

  %w[text ok close exists? present?].each do |name|
    doctest.before("Watir::Alert##{name}") do
      browser.goto WatirSpec.url_for('alerts.html')
      browser.button(id: 'alert').click
    end
  end

  doctest.before('Watir::Alert#set') do
    browser.goto WatirSpec.url_for('alerts.html')
    browser.button(id: 'prompt').click
  end

  %w[text exists? present?].each do |name|
    doctest.after("Watir::Alert##{name}") do
      browser.alert.close
    end
  end

  %w[Watir::Browser#execute_script Watir::Element#drag_and_drop].each do |name|
    doctest.before(name) do
      browser.goto WatirSpec.url_for('drag_and_drop.html')
    end
  end

  %w[attribute_value attribute].each do |name|
    doctest.before("Watir::Element##{name}") do
      browser.goto WatirSpec.url_for('non_control_elements.html')
    end
  end

  %w[Watir::JSExecution Watir::List].each do |name|
    doctest.before(name) do
      browser.goto WatirSpec.url_for('non_control_elements.html')
    end
  end

  %w[fire_event].each do |name|
    doctest.before("Watir::JSExecution##{name}") do
      browser.goto WatirSpec.url_for('forms_with_input_elements.html')
    end
  end

  doctest.before('Watir::Table') do
    browser.goto WatirSpec.url_for('tables.html')
  end

  %w[Watir::HasWindow Watir::Window#== Watir::Window#use].each do |name|
    doctest.before(name) do
      browser.goto WatirSpec.url_for('window_switching.html')
      browser.a(id: 'open').click
    end
  end

  doctest.after('Watir::Logger') do
    Watir.logger.level = :warn
  end

  doctest.after('Watir::AfterHooks') do
    browser.after_hooks.each do |hook|
      browser.after_hooks.delete(hook)
    end
  end
end

ENV['DISPLAY'] = ':99.0' if ENV['TRAVIS']
