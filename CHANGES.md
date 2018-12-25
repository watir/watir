### 6.16.5 (2018-12-25)

* Fix bug with nested elements using scopes (#842)

### 6.16.4 (2018-12-24)

* Minor adjustments to support locator extensions

### 6.16.3 (2018-12-24)

* Minor adjustments to support locator extensions

### 6.16.2 (2018-12-24)

* Fix bug merging scope when locating nested elements with css locator (#841)
* Fix bug with IFrame#to_subtype
* Improve performance for nested frames

### 6.16.1 (2018-12-23)

* Improve collection performance with JavaScript (thanks Lucas Tierney)
* Update deprecation warnings
* Improve performance when using previously located elements

### 6.16.0 (2018-12-16)

* Fix bug that did not re-locate Stale elements when taking an action on them (#814)
* Implement `Element#cache=` to assign otherwise located Selenium Element to `Element`
* Allow `:class` and `:class_name` locators to be used at the same time
* Allow `:class` locator with empty `Array` value to find all elements without a `class` attribute
* Fix bug that forced nested elements to wait when calling predicate methods (#827)
* Locator filtering behavior and Validate class moved into new `Matcher` classes
* Selector is built on Element initialization rather than during location
* Allow some nested elements to be located with a single XPath call
* Merge p0deje's watir-scroll gem functionality directly into Watir
* Fix bug with `#obscured?` for non-interactive elements (#818)

### 6.15.1 (2018-12-04)

* Locator value type check error message now returns array of allowed class types
* Wire calls for `:label` locator happen after Selector is built
* Improve error message for `Watir::Option` element when not found (#823)
* Wrap `#wd` with `#element_call` to wait for element to exist (#813)
* Remove automatic element reset in wait loop (#819)

### 6.15.0 (2018-11-07)

* Add `Element#selected_text`
* Add `Element#classes`
* Add `Element#obscured?`
* Deprecate `#wait_until_present` and `#wait_while_present`
* Improved Locator classes to reduce wire calls when using multiple/complex locators
* Fix bug with IE options
* Allow time values in yaml files for cookies (thanks Ryan Baumann)

### 6.14.0 (2018-09-13)

* HTML Element attribute support updated to HTML 5.2
* `#wait_until_present` and `#wait_while_present` accept custom message arguments (thanks Jakub Samek)
* Added `Element#located?` method
* Fix bug preventing collections from waiting for a parent element (#759)
* Fix bug preventing collection elements from being cached
* Update code style in accordance with Rubocop settings
* Add `Element#attribute_list` and `Element#attribute_values` (thanks Lakshya Kapoor)
* Fix bug preventing location of elements based on how XPath deals with default namespaces 
* Ruby 2.2 and below are no longer supported.

### 6.13.0 (2018-09-02)

* Allow wait methods to wait for values of any attribute
* Allow locating custom elements with adjacent methods
* Support how latest IEDrivers are handling stale elements
* Restore support for using of previously cached elements in collections
* Fix bug preventing clicking option when select list is not displayed
* Allow elements with content-editable attribute to use UserEditable module methods 

### 6.12.0 (2018-07-24)

* Allow elements to be located with attributes that have underscores (thanks John Fitisoff)
* Get array of elements from an Element Collection using a Range (#738)
* Deprecate using `#present?` or `#visible?` to determine if an element is stale
* Allow getting element attribute values with a Symbol
* Add new functionality to `#flash` (thanks Gijs Paulides)
* Fix bug preventing text_field from waiting until present (#675)
* Fix bug allowing `StaleElementReferenceError` during element location
* Add support for Wait methods to receive `Proc` as message values
* Add support to ignore specific warnings logged by Watir
* Deprecate locating elements by ordered parameters
* Changed scope for locator namespacing (Thanks Aleksandar)
* Deprecate current implementation of `#visible?`
* Update logic `#wait_while_present` and `#wait_until_present`
* Deprecate `#wait_while_present` and `#wait_until_present` for non-Element classes

### 6.11.0 (2018-05-18)

* Improve lazy loading of element collections
* Fix regressions (#726, #730)

### 6.11.0.beta2 (2018-05-10)

* Additional performance updates
* Fix bug with error message of unlocated parent element (#706)

### 6.11.0.beta1 (2018-05-04)

* Significant performance updates

### 6.10.3 (2018-01-26)

* Add special handling for `date_field` and `date_time_field` input types

### 6.10.2 (2017-12-13)

* Fix bug in `#exists?` for elements nested in IFrames

### 6.10.1 (2017-12-12)

* Fix bug in IFrame#present?
* Improve performance for Element#center (thanks Lucas Tierney)
* Skip tag name filter when locating by tag name

### 6.10.0 (2017-11-23)

* Add support for locating elements with custom attributes
* Add new `:visible_text` locator (thanks Justin Ko)
* Deprecate Selenium locators `:link`, `:link_text` and `:partial_link_text` in favor of `:visible_text`
* Deprecate finding only visible text for `RegExp` values on `:text` locator (#342)
* Improve support for finding elements with `:tag_name` along with `:xpath` or `:css` locators

### 6.9.1 (2017-11-20)

* Fix bug preventing the use of `#exectue_script` in `AfterHook` (#684)

### 6.9.0 (2017-11-18)

* Fix bug in Element#flash
* Fix bug with w3c alert handling (thanks Lakshya Kapoor)
* Add support for passing multiple options into #select and #select_all (thanks Justin Ko)
* Add support for passing multiple parameters into Element#set! (thanks Justin Ko) 
* Add support for headless Firefox (thanks Lucas Tierney)
* Add support for setting cookie expiration by String (thanks Lucas Tierney)
* Add support for new class locators to #element and #elements (thanks Justin Ko)
* Provide suggestion to look inside IFrame when element not found (thanks Justin Ko)

### 6.8.4 (2017-09-08)

* Fix bug with non-visible buttons not being waited on (#648)

### 6.8.3 (2017-09-07)

* Fix bug with non-interactable elements not being waited on (#636)

### 6.8.2 (2017-09-06)

* Fix bug to prevent after_hooks from running when an alert is present
* Fix bug with actions not correctly timing out (#636)

### 6.8.1 (2017-09-05)

* Ignore index locator when value is zero
* Fix bug with `Select#select!` doing partial string matches (thanks Justin Ko )

### 6.8.0 (2017-08-28)

* Add AfterHook executions to additional methods that can change DOM
* Deprecate `Select#select_value` in favor of `Select#select`
* Implement `Element` `#click!`, `#double_click!` & `#set!` with JavaScript
* Implement `Select#select!` and `Select#select_all!` with JavaScript
* Implement `Element#inner_text` and `Element#text_content`
* Implement `RadioSet`
* Implement `Input#label`
* Fix bug preventing Capabilities from handling :listener

### 6.7.3 (2017-08-20)

* Fix bug preventing Capabilities from handling :driver_opts (#629)

### 6.7.2 (2017-08-18)

* TableCell#column_header returns String not Cell

### 6.7.1 (2017-08-16)

* Fix bug preventing use of Firefox profiles (#625)

### 6.7.0 (2017-08-14)

* Implement TableCell#column_header
* Add aliases to access Element methods in more ways
* Add methods on Element #scroll_into_view #location #size #height #center
* Fix bug preventing Safari Technology Preview usage
* Implement Browser#original_window
* Implement TableCell#sibling_from_header
* Fix bug preventing usage of switches with Chrome
* Fix bug of not waiting for SelectList when using options
* Allow OList, UList, TableRow, Table to be accessed like collections
* Implement Element#siblings
* Fix bug preventing locating elements by attribute

### 6.6.3 (2017-08-09)

* Fix bug preventing usage of remote driver (#614)
* HTML Element attribute support updated to HTML 5.1 

### 6.6.2 (2017-08-08)

* Fix bug preventing headless operation (#611)

### 6.6.1 (2017-08-07)

* Support initializing browser with Selenium Options class (#606)

### 6.6.0 (2017-08-02)

* Implement `Select#select_all` for selecting multiple options in select list
* Deprecate `Select#select` for selecting multiple options in a list
* Implement `ElementCollection#empty?` and `ElementCollection#locate?`
* Implement `Watir::Logger` class
* Implement `Watir::Capabilities` class
* Add support for relocating elements created with `Element#to_subtype`
* Add support for locating adjacent elements with any Watir locator 
* Allow locating buttons by type attribute (thanks Justin Ko )

### 6.5.0 (2017-07-25)

* Add support for locating multiple classes using :class parameter 

### 6.4.3 (2017-07-19)

* Fix bug with element relocation from ElementCollection 

### 6.4.2 (2017-07-14)

* No changes 

### 6.4.1 (2017-07-13)

* Fix bug with stale element errors from ElementCollection (#571) 

### 6.4.0 (2017-07-11)

* Significant performance updates

### 6.3.0 (2017-06-20)

* Allow locating elements by attribute presence/absence (#345)
* Element#flash configurable by color, number, and delay (thanks Paul3816547290)
* Implement Select#text like Select#value (thanks Arik Jones)
* Optimize Select#selected_options, Select#value, and Select#text with javascript (thanks Andrei Botalov)
* Support locating elements by #execute_script from inside frame context

### 6.2.1 (2017-03-22)

* Allow sending text to FileField without checking element is #visible?
* Fix bug waiting for Alerts
* Fix bug from resetting stale element (thanks DJCecil2)

### 6.2.0 (2017-02-20)

* `Element#wait_while_present` exits when locator no longer matches
* Element Collections store specific element types rather than just `HTMLElement`
* Implement adjacent element location for parent, siblings and children
* Add support for assigning keywords to `Element` for better error messaging
* Update actions implementation to work with selenium-webdriver > 3.0.5

### 6.1.0 (2017-01-04)

* Add Ruby 2.4.0 support (thanks Robert MacCracken)
* Implement polling interval parameter for wait methods
* Implement visible locator for element collections
* Implement automatic waiting for selecting options in a select list
* Fix bug allowing `StaleElementReferenceError` in `#wait_while_present` calls

### 6.0.3 (2016-12-22)

* No notable changes, only includes fixes for WatirSpec

### 6.0.2 (2016-11-15)

* Fix bug for `Timer#current_time` calling the wrong `Time`

### 6.0.1 (2016-11-09)

* Fix bug for `Browser#wait_until` and `wait_while` to allow ordered arguments

### 6.0.0 (2016-11-08)

* Add `#Watir#relaxed_locate` to enable automatic waiting for elements to be ready for a specified action
* Remove `when_present` method
* Update `wait_until` and `wait_while` to return `self` to allow chaining
* Support keywords for wait methods
* `Element#text_field` no longer locates textareas - use `Element#textarea` instead.
* Use `Process.clock_gettime` when available for waiting (#486)

### 6.0.0.beta5 (2016-09-25)

* Elements in collections can now be relocated after going stale
* Added visible locator to filter out matching elements that are hidden
* Element not found error messages now include selector information from parent elements

### 6.0.0.beta4 (2016-09-12)

* Deprecate Watir#prefer_css setting
* Deprecate Watir#always_locate setting
* Add `Element#stale?`
* Add `Element#wait_until_stale`
* Allow locating date/time/etc. input types with `#text_field` (#295)

### 6.0.0.beta3 (2016-08-07)

* Deprecate `require "watir-webdriver"` in favor of `require "watir"`

### 6.0.0.beta2 (2016-08-06)

* Support projects with files using `require "watir-webdriver"`

### 6.0.0.beta1 (2016-08-06)

* Project renamed to watir
* References to WebDriver removed or replaced by Selenium
* Require Selenium > 3.0.0.beta1
* Default browser in Watir is now Chrome
* Default implementation for Firefox is with geckodriver
* Remove deprecated alerts helpers
* Remove deprecated checkers

### 0.9.9 (2016-08-01)

* Final release as watir-webdriver

### 0.9.3 (2016-07-31)

* Fix warning message for untyped text field (#434)

### 0.9.2 (2016-07-29)

* Massive reorganization and refactoring of element locators (#392)
* Fix bug with when_present (#432)
* Bug fix for elements in collections going stale

### 0.9.1 (2015-10-14)

* Fix permissions issue with element_locator file(#381)
* Trying to select a disabled option now raises `ObjectDisabledException` (#378)
* `Element#enabled?` raises `UnknownObjectException` if element is not present (#379)

### 0.9.0 (2015-10-08)

* Improve performance for Select#include? (#375, thanks @Conky5)
* Add support for waiting for elements to be enabled (#370, thanks @Rodney-QAGeek)
* Remove unnecessary wire calls for navigation (#369)
* Improve performance for Select#selected? with large drop-down lists (#367)
* Add stale element protection and correct context assurance for Browser#text (#366)
* Restore behavior for Wait#until to return result of block (#362, thanks @chrismikehogan)
* Fix context switching between frames for element collections (#361)
* AfterHooks run after closing an alert (#352)
* New AfterHooks API that deprecates Checkers:
  * Use `Browser#after_hooks#add` instead of `Browser#add_checker`
  * Use `Browser#after_hooks#delete` instead of `Browser#disable_checker`
  * Use `Browser#after_hooks#run` instead of `Browser#run_checkers`
  * Use `Browser#after_hooks#without` instead of `Browser#without_checkers`

### 0.8.0 (2015-06-26)

* Ruby 1.8 is no longer supported. Ruby 1.9 still works, but not supported as well (#327)
* Ensure `Watir::Element` responds to `data_*` and `aria_*` methods (#333, thanks @daneandersen)
* Fixed the handling of child elements becoming stale (#321)
* Performance optimization for nested elements (#321)
* Support for SVG elements (see `lib/watir-webdriver/elements/svg_elements.rb`)
* Updated selenium-webdriver to 2.46.2

### 0.7.0 (2015-03-02)

* Allow finding all elements with prefer_css
* Add support for yard-doctest (#287)
* Update from HTML spec (#296)
* Support tag_name call on Frames and IFrames (#293 & #294)
* Increased performance by caching elements by default where possible (#307)
* Improved handling of elements that go stale during lookup (#291, thanks @titusfortner)
* Fix element location issues when switching between IFrames (#286, thanks @titusfortner)
* Fix creation of an IFrameCollection based on selector (#299, thanks @titusfortner)
* Fix window handling with closed windows (#290 & 282, thanks @titusfortner)
* Prevent running checkers on a closed window (#283, thanks @titusfortner)
* Allow taking actions without triggering run checkers (#283, thanks @titusfortner)
* Fix bug when ElementCollection#[] returns existing elements for non-existing selector (#309)
* Fix bug when Wait would never execute block with 0 timeout (#312)
* Fix race condition with IFrameCollection#to_a (#317)

### 0.6.11 (2014-09-23)

* Fix namespacing issue (#265, thanks @titusfortner)
* Fix handling of elements that go stale during lookup (#271, thanks @titusfortner)

### 0.6.10 (2014-06-10)

* Changed the way attributes are generated and documented (see #28 and #215)
* Improved error message for read only elements (see #256)

### 0.6.9 (2014-04-13)

* `Watir::Wait` timer can be re-implemented now (see #242)
* Added `Watir::Cookies#[]` to retrieve cookie by name (see #251, thanks @mattparlane)
* Added `Watir::Element#outer_html` (aliased to `#html`) (thanks @aderyabin)
* Added `Watir::Element#inner_html` (thanks @aderyabin)

### 0.6.8 (2014-02-20)

* `:css` selector can now be used with `:index` (fixes #241)
* `:css` selector can now be used on all container methods (fixes #124)

### 0.6.7 (2014-02-04)

* Revert wait/timeout bug introduced in 0.6.5 to fix #228.

### 0.6.6 (2014-01-29)

* Fix regression where locating `<button>foo</button>` using (value: /foo/) would fail.

### 0.6.5 (2014-01-28)

* Allow :name as locator for any element (#238)
* Make default timeout configurable (Watir.default_timeout, thanks to Justin Ko)
* Fix collission with Timecop. (#228)
* Support locating elements by and retrieving value of `aria-*` attributes. (#233)
* Allow to save/load cookies from file (thanks @ar4an)
* Locate by label attribute if it's valid for element (#219)
* Delegate #present? to Element (#216)
* Handle iframes like frames (#204)
* Fix HTML5 / input type handling (#217)
* Fix locating buttons and textarea by value (#163, #208)
* Make sure Browser#url always returns url of top frame (#205).
* Deprecate locating texteareas with #text_field.

### 0.6.4

* Add ability to find element by parent <label>

### 0.6.3

* Always use custom YARD handler (should give full docs on rubydoc.info)
* Window resizing coerces string arguments

### 0.6.2

* Update from HTML spec (adds :abbr attribute to TableHeaderCell).
* Add Window#maximize. Closes #153.
* Add Browser#name.
* Documentation improvements.
* Don't overwrite original element color in Element#flash. Closes #171.
* Return the element itself when Element#flash is called.
* Fix case sensitivity issues when locating elements. Closes #72.

### 0.6.1

   Added objects:

     Watir::DList#to_hash (lib/watir-webdriver/elements/dlist.rb:4)

   Modified objects:

     Watir::Alert#exists? (lib/watir-webdriver/alert.rb:32)
     Watir::Alert#present? (lib/watir-webdriver/alert.rb:38)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.6.0

   Added objects:

     Watir::Alert (lib/watir-webdriver/alert.rb:3)
     Watir::Alert#close (lib/watir-webdriver/alert.rb:22)
     Watir::Alert#exists? (lib/watir-webdriver/alert.rb:32)
     Watir::Alert#initialize (lib/watir-webdriver/alert.rb:7)
     Watir::Alert#ok (lib/watir-webdriver/alert.rb:17)
     Watir::Alert#present? (lib/watir-webdriver/alert.rb:38)
     Watir::Alert#selector_string (lib/watir-webdriver/alert.rb:40)
     Watir::Alert#set (lib/watir-webdriver/alert.rb:27)
     Watir::Alert#text (lib/watir-webdriver/alert.rb:12)
     Watir::Browser#alert (lib/watir-webdriver/browser.rb:105)
     Watir::Browser#screenshot (lib/watir-webdriver/browser.rb:148)
     Watir::Screenshot (lib/watir-webdriver/screenshot.rb:3)
     Watir::Screenshot#base64 (lib/watir-webdriver/screenshot.rb:35)
     Watir::Screenshot#initialize (lib/watir-webdriver/screenshot.rb:5)
     Watir::Screenshot#png (lib/watir-webdriver/screenshot.rb:25)
     Watir::Screenshot#save (lib/watir-webdriver/screenshot.rb:15)

   Modified objects:

     Watir::AlertHelper#alert (lib/watir-webdriver/extensions/alerts.rb:22)
     Watir::AlertHelper#confirm (lib/watir-webdriver/extensions/alerts.rb:38)
     Watir::AlertHelper#prompt (lib/watir-webdriver/extensions/alerts.rb:55)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.5.8

   Modified objects:

     Watir::ElementLocator#locate (lib/watir-webdriver/locators/element_locator.rb:25)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.5.7

   Added objects:

     Watir::HTML::SpecExtractor#fetch_interface (lib/watir-webdriver/html/spec_extractor.rb:41)

   Modified objects:

     Watir::Cookies#add (lib/watir-webdriver/cookies.rb:13)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.5.6

   Added objects:

     Watir::Container#dialog (lib/watir-webdriver/elements/generated.rb:1267)
     Watir::Container#dialogs (lib/watir-webdriver/elements/generated.rb:1275)
     Watir::Dialog (lib/watir-webdriver/elements/generated.rb:134)
     Watir::DialogCollection (lib/watir-webdriver/elements/generated.rb:137)
     Watir::DialogCollection#element_class (lib/watir-webdriver/elements/generated.rb:138)

   Modified objects:

     Watir::Browser#inspect (lib/watir-webdriver/browser.rb:47)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.5.5

   Modified objects:

     Watir::Browser#inspect (lib/watir-webdriver/browser.rb:47)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)

   Removed objects:

     Watir::Browser#clear_cookies (lib/watir-webdriver/browser.rb:90)


### 0.5.4

   Added objects:

     Watir.prefer_css= (lib/watir-webdriver.rb:46)
     Watir.prefer_css? (lib/watir-webdriver.rb:37)

   Modified objects:

     Watir::ElementLocator::WD_FINDERS (lib/watir-webdriver/locators/element_locator.rb:6)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)

   Removed objects:

     Watir::Frame#element_by_xpath (lib/watir-webdriver/elements/frame.rb:45)
     Watir::Frame#elements_by_xpath (lib/watir-webdriver/elements/frame.rb:50)


### 0.5.3

   Added objects:

     Watir::Element#browser (lib/watir-webdriver/elements/element.rb:349)

   Modified objects:

     Watir::Element#initialize (lib/watir-webdriver/elements/element.rb:25)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.5.2

   Modified objects:

     Watir::Element#parent (lib/watir-webdriver/elements/element.rb:252)
     Watir::Element#value (lib/watir-webdriver/elements/element.rb:204)
     Watir::ElementLocator#locate (lib/watir-webdriver/locators/element_locator.rb:26)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.5.1

   Added objects:

     Watir::Browser#cookies (lib/watir-webdriver/browser.rb:95)
     Watir::Cookies (lib/watir-webdriver/cookies.rb:2)
     Watir::Cookies#add (lib/watir-webdriver/cookies.rb:13)
     Watir::Cookies#clear (lib/watir-webdriver/cookies.rb:25)
     Watir::Cookies#delete (lib/watir-webdriver/cookies.rb:21)
     Watir::Cookies#initialize (lib/watir-webdriver/cookies.rb:3)
     Watir::Cookies#to_a (lib/watir-webdriver/cookies.rb:7)

   Modified objects:

     Watir::Browser#clear_cookies (lib/watir-webdriver/browser.rb:90)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)

   Removed objects:

     Watir::XpathSupport#element_by_xpath (lib/watir-webdriver/xpath_support.rb:10)
     Watir::XpathSupport#elements_by_xpath (lib/watir-webdriver/xpath_support.rb:23)


### 0.5.0

   Added objects:

     Watir::Container#field_set (lib/watir-webdriver/aliases.rb:3)
     Watir::Container#field_sets (lib/watir-webdriver/aliases.rb:4)
     Watir::Container#frameset (lib/watir-webdriver/elements/generated.rb:1424)
     Watir::Container#framesets (lib/watir-webdriver/elements/generated.rb:1432)
     Watir::Container#time (lib/watir-webdriver/elements/generated.rb:2478)
     Watir::Container#times (lib/watir-webdriver/elements/generated.rb:2486)
     Watir::Element#drag_and_drop_by (lib/watir-webdriver/elements/element.rb:186)
     Watir::Element#drag_and_drop_on (lib/watir-webdriver/elements/element.rb:166)
     Watir::Element#focused? (lib/watir-webdriver/elements/element.rb:240)
     Watir::Element#hover (lib/watir-webdriver/elements/element.rb:148)
     Watir::Option#clear (lib/watir-webdriver/elements/option.rb:28)
     Watir::Time (lib/watir-webdriver/elements/generated.rb:529)
     Watir::TimeCollection (lib/watir-webdriver/elements/generated.rb:532)
     Watir::TimeCollection#element_class (lib/watir-webdriver/elements/generated.rb:533)
     Watir::UserEditable (lib/watir-webdriver/user_editable.rb:2)
     Watir::UserEditable#<< (lib/watir-webdriver/user_editable.rb:26)
     Watir::UserEditable#append (lib/watir-webdriver/user_editable.rb:20)
     Watir::UserEditable#clear (lib/watir-webdriver/user_editable.rb:32)
     Watir::UserEditable#set (lib/watir-webdriver/user_editable.rb:7)
     Watir::UserEditable#value= (lib/watir-webdriver/user_editable.rb:14)
     Watir::WhenPresentDecorator#respond_to? (lib/watir-webdriver/wait.rb:75)

   Modified objects:

     Watir::Element#click (lib/watir-webdriver/elements/element.rb:73)
     Watir::Element#double_click (lib/watir-webdriver/elements/element.rb:80)
     Watir::Element#right_click (lib/watir-webdriver/elements/element.rb:91)
     Watir::Image#loaded? (lib/watir-webdriver/elements/image.rb:5)
     Watir::Select#selected_options (lib/watir-webdriver/elements/select.rb:117)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)

   Removed objects:

     Watir::TextField#append (lib/watir-webdriver/elements/text_field.rb:25)
     Watir::TextField#clear (lib/watir-webdriver/elements/text_field.rb:36)
     Watir::TextField#set (lib/watir-webdriver/elements/text_field.rb:12)
     Watir::TextField#value= (lib/watir-webdriver/elements/text_field.rb:19)


### 0.4.1

   Modified objects:

     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.4.0

   Modified objects:

     Watir::AlertHelper#prompt (lib/watir-webdriver/extensions/alerts.rb:55)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)
     Watir::XpathSupport#element_by_xpath (lib/watir-webdriver/xpath_support.rb:10)
     Watir::XpathSupport#elements_by_xpath (lib/watir-webdriver/xpath_support.rb:21)

   Removed objects:

     Object (lib/watir-webdriver.rb:86)


### 0.3.9

   Added objects:

     Watir::Container#data (lib/watir-webdriver/elements/generated.rb:1156)
     Watir::Container#detailses (lib/watir-webdriver/elements/generated.rb:1232)
     Watir::Data (lib/watir-webdriver/elements/generated.rb:541)
     Watir::DataCollection (lib/watir-webdriver/elements/generated.rb:544)
     Watir::DataCollection#element_class (lib/watir-webdriver/elements/generated.rb:545)
     Watir::HasWindow (lib/watir-webdriver/has_window.rb:2)
     Watir::HasWindow#window (lib/watir-webdriver/has_window.rb:13)
     Watir::HasWindow#windows (lib/watir-webdriver/has_window.rb:3)
     Watir::Window#move_to (lib/watir-webdriver/window.rb:45)
     Watir::Window#position (lib/watir-webdriver/window.rb:31)
     Watir::Window#resize_to (lib/watir-webdriver/window.rb:38)
     Watir::Window#size (lib/watir-webdriver/window.rb:24)

   Modified objects:

     Watir::Element#present? (lib/watir-webdriver/elements/element.rb:187)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)
     Watir::Window#present? (lib/watir-webdriver/window_switching.rb:64)

   Removed objects:

     Watir::Container#time (lib/watir-webdriver/elements/generated.rb:2438)
     Watir::Container#times (lib/watir-webdriver/elements/generated.rb:2446)
     Watir::Time (lib/watir-webdriver/elements/generated.rb:527)
     Watir::TimeCollection (lib/watir-webdriver/elements/generated.rb:530)
     Watir::TimeCollection#element_class (lib/watir-webdriver/elements/generated.rb:531)
     Watir::WindowSwitching (lib/watir-webdriver/window_switching.rb:2)
     Watir::WindowSwitching#window (lib/watir-webdriver/window_switching.rb:14)
     Watir::WindowSwitching#windows (lib/watir-webdriver/window_switching.rb:4)


### 0.3.8

   Modified objects:

     Watir::Element#present? (lib/watir-webdriver/elements/element.rb:187)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.3.7

   Modified objects:

     Watir::Element#present? (lib/watir-webdriver/elements/element.rb:187)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.3.6

   Modified objects:

     Watir::VERSION (lib/watir-webdriver/version.rb:2)
     Watir::Window#present? (lib/watir-webdriver/window_switching.rb:63)


### 0.3.5

   Modified objects:

     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.3.4

   Modified objects:

     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.3.3

   Modified objects:

     Watir::Browser#goto (lib/watir-webdriver/browser.rb:58)
     Watir::Element#double_click (lib/watir-webdriver/elements/element.rb:71)
     Watir::Element#right_click (lib/watir-webdriver/elements/element.rb:82)
     Watir::TextFieldLocator::NON_TEXT_TYPES (lib/watir-webdriver/locators/text_field_locator.rb:4)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.3.2

   Modified objects:

     Watir::Frame#assert_exists (lib/watir-webdriver/elements/frame.rb:16)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.3.1

   Added objects:

     Watir.always_locate= (lib/watir-webdriver.rb:34)
     Watir.always_locate? (lib/watir-webdriver.rb:25)

   Modified objects:

     Watir::Frame#assert_exists (lib/watir-webdriver/elements/frame.rb:16)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)

   Removed objects:

     Watir.element_class_for (lib/watir-webdriver.rb:27)
     Watir.tag_to_class (lib/watir-webdriver.rb:23)


### 0.3.0

   Modified objects:

     Watir::Element#fire_event (lib/watir-webdriver/elements/element.rb:138)
     Watir::Element#parent (lib/watir-webdriver/elements/element.rb:144)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.2.9

   Added objects:

     Watir::Atoms (lib/watir-webdriver/atoms.rb:2)
     Watir::Atoms.load (lib/watir-webdriver/atoms.rb:6)
     Watir::Atoms::ATOMS (lib/watir-webdriver/atoms.rb:4)
     Watir::Container#extract_selector (lib/watir-webdriver/container.rb:15)
     Watir::Element#select_text (lib/watir-webdriver/extensions/select_text.rb:5)

   Modified objects:

     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.2.8

   Modified objects:

     Watir::Element#initialize (lib/watir-webdriver/elements/element.rb:17)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.2.7

   Added objects:

     Watir::Browser#reset! (lib/watir-webdriver/browser.rb:171)
     Watir::Container#u (lib/watir-webdriver/elements/generated.rb:2506)
     Watir::Container#us (lib/watir-webdriver/elements/generated.rb:2514)

   Modified objects:

     Watir::Frame#locate (lib/watir-webdriver/elements/frame.rb:5)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.2.6

   Modified objects:

     Watir::Element#double_click (lib/watir-webdriver/elements/element.rb:75)
     Watir::Element#right_click (lib/watir-webdriver/elements/element.rb:83)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.2.5

   Modified objects:

     Watir::Option#select (lib/watir-webdriver/elements/option.rb:14)
     Watir::Option#toggle (lib/watir-webdriver/elements/option.rb:25)
     Watir::Select#clear (lib/watir-webdriver/elements/select.rb:20)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.2.4

   Added objects:

     Watir::Frame#html (lib/watir-webdriver/elements/frame.rb:23)
     Watir::XpathSupport.escape (lib/watir-webdriver/xpath_support.rb:27)

   Modified objects:

     Watir::Container#iframe (lib/watir-webdriver/elements/generated.rb:1601)
     Watir::Container#iframes (lib/watir-webdriver/elements/generated.rb:1609)
     Watir::Element#fire_event (lib/watir-webdriver/elements/element.rb:136)
     Watir::Element#html (lib/watir-webdriver/elements/element.rb:115)
     Watir::Element#parent (lib/watir-webdriver/elements/element.rb:142)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.2.3

   Added objects:

     Watir::FrameCollection#to_a (lib/watir-webdriver/elements/frame.rb:61)

   Modified objects:

     Watir::Frame#assert_exists (lib/watir-webdriver/elements/frame.rb:14)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)

   Removed objects:

     Watir::Device (lib/watir-webdriver/elements/generated.rb:110)
     Watir::DeviceCollection (lib/watir-webdriver/elements/generated.rb:113)
     Watir::DeviceCollection#element_class (lib/watir-webdriver/elements/generated.rb:114)
     Watir::PerformanceHelper (lib/watir-webdriver/extensions/performance.rb:14)
     Watir::PerformanceHelper#performance (lib/watir-webdriver/extensions/performance.rb:16)
     Watir::PerformanceHelper::Performance (lib/watir-webdriver/extensions/performance.rb:21)
     Watir::PerformanceHelper::Performance#initialize (lib/watir-webdriver/extensions/performance.rb:24)
     Watir::PerformanceHelper::Performance#memory (lib/watir-webdriver/extensions/performance.rb:22)
     Watir::PerformanceHelper::Performance#navigation (lib/watir-webdriver/extensions/performance.rb:22)
     Watir::PerformanceHelper::Performance#timing (lib/watir-webdriver/extensions/performance.rb:22)


### 0.2.2

   Modified objects:

     Watir::Element#value (lib/watir-webdriver/elements/element.rb:100)
     Watir::Image#file_created_date (lib/watir-webdriver/elements/image.rb:29)
     Watir::Image#file_size (lib/watir-webdriver/elements/image.rb:34)
     Watir::Image#save (lib/watir-webdriver/elements/image.rb:39)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)
     Watir::Window#initialize (lib/watir-webdriver/window_switching.rb:40)
     Watir::WindowSwitching#windows (lib/watir-webdriver/window_switching.rb:4)

   Removed objects:

     Watir::FileField#value (lib/watir-webdriver/elements/file_field.rb:39)
     Watir::TextField#value (lib/watir-webdriver/elements/text_field.rb:45)


### 0.2.1

   Modified objects:

     Watir::Browser#execute_script (lib/watir-webdriver/browser.rb:122)
     Watir::Button#text (lib/watir-webdriver/elements/button.rb:24)
     Watir::Element#== (lib/watir-webdriver/elements/element.rb:46)
     Watir::Element#eql? (lib/watir-webdriver/elements/element.rb:52)
     Watir::Element#parent (lib/watir-webdriver/elements/element.rb:142)
     Watir::Element#style (lib/watir-webdriver/elements/element.rb:181)
     Watir::Element#tag_name (lib/watir-webdriver/elements/element.rb:63)
     Watir::Element#to_subtype (lib/watir-webdriver/elements/element.rb:202)
     Watir::Element#value (lib/watir-webdriver/elements/element.rb:100)
     Watir::FramedDriver#eql? (lib/watir-webdriver/elements/frame.rb:76)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)
     Watir::XpathSupport#element_by_xpath (lib/watir-webdriver/xpath_support.rb:10)
     Watir::XpathSupport#elements_by_xpath (lib/watir-webdriver/xpath_support.rb:21)

   Removed objects:

     Watir::Element#driver (lib/watir-webdriver/elements/element.rb:152)
     Watir::Element#element (lib/watir-webdriver/elements/element.rb:156)
     Watir::Element#wd (lib/watir-webdriver/elements/element.rb:160)


### 0.2.0

   Added objects:

     Watir::Browser#ready_state (lib/watir-webdriver/browser.rb:114)
     Watir::Browser#wait (lib/watir-webdriver/browser.rb:108)

   Modified objects:

     Watir::Browser#goto (lib/watir-webdriver/browser.rb:58)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.2.0.dev2

   Added objects:

     Watir::Browser#exists? (lib/watir-webdriver/browser.rb:159)
     Watir::Wait::INTERVAL (lib/watir-webdriver/wait.rb:8)
     Watir::Waitable (lib/watir-webdriver/wait.rb:53)
     Watir::Waitable#wait_until (lib/watir-webdriver/wait.rb:54)
     Watir::Waitable#wait_while (lib/watir-webdriver/wait.rb:58)

   Modified objects:

     Watir::Browser#add_checker (lib/watir-webdriver/browser.rb:122)
     Watir::Browser#run_checkers (lib/watir-webdriver/browser.rb:136)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)
     Watir::Wait.until (lib/watir-webdriver/wait.rb:14)
     Watir::Wait.while (lib/watir-webdriver/wait.rb:30)
     Watir::Window#exists? (lib/watir-webdriver/window_switching.rb:62)
     Watir::Window#present? (lib/watir-webdriver/window_switching.rb:68)

   Removed objects:

     Watir::WindowSwitching::NoMatchingWindowFoundException (lib/watir-webdriver/window_switching.rb:4)


### 0.2.0.dev

   Modified objects:

     Watir::VERSION (lib/watir-webdriver/version.rb:2)
     Watir::Window#use (lib/watir-webdriver/window_switching.rb:103)


### 0.1.9

   Added objects:

     Watir::Browser#send_keys (lib/watir-webdriver/browser.rb:118)
     Watir::EventuallyPresent (lib/watir-webdriver/wait.rb:81)
     Watir::EventuallyPresent#wait_until_present (lib/watir-webdriver/wait.rb:115)
     Watir::EventuallyPresent#wait_while_present (lib/watir-webdriver/wait.rb:129)
     Watir::EventuallyPresent#when_present (lib/watir-webdriver/wait.rb:95)
     Watir::Window#exists? (lib/watir-webdriver/window_switching.rb:62)
     Watir::Window#present? (lib/watir-webdriver/window_switching.rb:68)

   Modified objects:

     Watir::VERSION (lib/watir-webdriver/version.rb:2)
     Watir::Wait.until (lib/watir-webdriver/extensions/wait.rb:20)
     Watir::Wait.while (lib/watir-webdriver/extensions/wait.rb:36)
     Watir::WhenPresentDecorator#initialize (lib/watir-webdriver/extensions/wait.rb:55)
     Watir::WhenPresentDecorator#method_missing (lib/watir-webdriver/extensions/wait.rb:60)
     Watir::Window#== (lib/watir-webdriver/window_switching.rb:55)
     Watir::Window#current? (lib/watir-webdriver/window_switching.rb:66)
     Watir::Window#eql? (lib/watir-webdriver/window_switching.rb:60)
     Watir::Window#hash (lib/watir-webdriver/window_switching.rb:62)
     Watir::Window#initialize (lib/watir-webdriver/window_switching.rb:47)
     Watir::Window#inspect (lib/watir-webdriver/window_switching.rb:51)
     Watir::Window#use (lib/watir-webdriver/window_switching.rb:88)
     Watir::WindowSwitching#window (lib/watir-webdriver/window_switching.rb:17)
     Watir::WindowSwitching#windows (lib/watir-webdriver/window_switching.rb:7)

   Removed objects:

     Watir::Element#wait_until_present (lib/watir-webdriver/extensions/wait.rb:118)
     Watir::Element#wait_while_present (lib/watir-webdriver/extensions/wait.rb:133)
     Watir::Element#when_present (lib/watir-webdriver/extensions/wait.rb:98)


### 0.1.8

   Added objects:

     Watir::FramedDriver#eql? (lib/watir-webdriver/elements/frame.rb:76)

   Modified objects:

     Watir::Browser#execute_script (lib/watir-webdriver/browser.rb:111)
     Watir::Container#frames (lib/watir-webdriver/elements/frame.rb:106)
     Watir::Frame#assert_exists (lib/watir-webdriver/elements/frame.rb:26)
     Watir::Frame#locate (lib/watir-webdriver/elements/frame.rb:12)
     Watir::VERSION (lib/watir-webdriver/version.rb:2)

   Removed objects:

     String (lib/watir-webdriver/core_ext/string.rb:2)
     String#camel_case (lib/watir-webdriver/core_ext/string.rb:19)
     String#snake_case (lib/watir-webdriver/core_ext/string.rb:9)
     Watir::Button.from (lib/watir-webdriver/elements/button.rb:17)
     Watir::CheckBox.from (lib/watir-webdriver/elements/checkbox.rb:6)
     Watir::FileField.from (lib/watir-webdriver/elements/file_field.rb:4)
     Watir::Frame#initialize (lib/watir-webdriver/elements/frame.rb:7)
     Watir::Frame::VALID_LOCATORS (lib/watir-webdriver/elements/frame.rb:5)
     Watir::Radio.from (lib/watir-webdriver/elements/radio.rb:4)
     Watir::TextField.from (lib/watir-webdriver/elements/text_field.rb:8)


### 0.1.7

   Modified objects:

     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.1.6

   Modified objects:

     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.1.5

   Added objects:

     Watir::VERSION (lib/watir-webdriver/version.rb:2)


### 0.1.4

   Modified objects:

     Watir::AlertHelper#prompt (lib/watir-webdriver/extensions/alerts.rb:55)


### 0.1.3



### 0.1.2

   Added objects:

     Watir::Container#bdi (lib/watir-webdriver/elements/generated.rb:914)
     Watir::Container#bdis (lib/watir-webdriver/elements/generated.rb:922)

   Modified objects:

     Watir::HTML::SpecExtractor#process (lib/watir-webdriver/html/spec_extractor.rb:10)


### 0.1.1

   Added objects:

     Watir::Container#s (lib/watir-webdriver/elements/generated.rb:2068)
     Watir::Container#ss (lib/watir-webdriver/elements/generated.rb:2076)
     Watir::RowContainer#strings (lib/watir-webdriver/row_container.rb:24)
     Watir::RowContainer#to_a (lib/watir-webdriver/row_container.rb:31)

   Removed objects:

     Watir::Table#strings (lib/watir-webdriver/elements/table.rb:13)
     Watir::Table#to_a (lib/watir-webdriver/elements/table.rb:20)


### 0.1.0

   Added objects:

     Watir::AlertHelper (lib/watir-webdriver/extensions/alerts.rb:9)
     Watir::AlertHelper#alert (lib/watir-webdriver/extensions/alerts.rb:22)
     Watir::AlertHelper#confirm (lib/watir-webdriver/extensions/alerts.rb:38)
     Watir::AlertHelper#prompt (lib/watir-webdriver/extensions/alerts.rb:55)
     Watir::Button::VALID_TYPES (lib/watir-webdriver/elements/button.rb:15)
     Watir::CellContainer (lib/watir-webdriver/cell_container.rb:2)
     Watir::CellContainer#cell (lib/watir-webdriver/cell_container.rb:4)
     Watir::CellContainer#cells (lib/watir-webdriver/cell_container.rb:11)
     Watir::ChildCellLocator (lib/watir-webdriver/locators/child_cell_locator.rb:2)
     Watir::ChildCellLocator#locate_all (lib/watir-webdriver/locators/child_cell_locator.rb:4)
     Watir::ChildRowLocator (lib/watir-webdriver/locators/child_row_locator.rb:2)
     Watir::ChildRowLocator#locate_all (lib/watir-webdriver/locators/child_row_locator.rb:4)
     Watir::Container#element (lib/watir-webdriver/container.rb:6)
     Watir::Container#elements (lib/watir-webdriver/container.rb:10)
     Watir::Element#to_subtype (lib/watir-webdriver/elements/element.rb:186)
     Watir::PerformanceHelper (lib/watir-webdriver/extensions/performance.rb:14)
     Watir::PerformanceHelper#performance (lib/watir-webdriver/extensions/performance.rb:16)
     Watir::PerformanceHelper::Performance (lib/watir-webdriver/extensions/performance.rb:21)
     Watir::PerformanceHelper::Performance#initialize (lib/watir-webdriver/extensions/performance.rb:24)
     Watir::PerformanceHelper::Performance#memory (lib/watir-webdriver/extensions/performance.rb:22)
     Watir::PerformanceHelper::Performance#navigation (lib/watir-webdriver/extensions/performance.rb:22)
     Watir::PerformanceHelper::Performance#timing (lib/watir-webdriver/extensions/performance.rb:22)
     Watir::RowContainer (lib/watir-webdriver/row_container.rb:2)
     Watir::RowContainer#row (lib/watir-webdriver/row_container.rb:4)
     Watir::RowContainer#rows (lib/watir-webdriver/row_container.rb:11)
     Watir::Table#hashes (lib/watir-webdriver/elements/table.rb:22)
     Watir::Table#strings (lib/watir-webdriver/elements/table.rb:13)
     Watir::TableCell#colspan (lib/watir-webdriver/elements/table_cell.rb:10)
     Watir::TableCell#locator_class (lib/watir-webdriver/elements/table_cell.rb:6)
     Watir::TableCellCollection#elements (lib/watir-webdriver/elements/table_cell.rb:23)
     Watir::TableCellCollection#locator_class (lib/watir-webdriver/elements/table_cell.rb:19)
     Watir::TableCellCollection#locator_class= (lib/watir-webdriver/elements/table_cell.rb:17)
     Watir::TableRowCollection#elements (lib/watir-webdriver/elements/table_row.rb:29)
     Watir::TableRowCollection#locator_class (lib/watir-webdriver/elements/table_row.rb:41)
     Watir::TableRowCollection#locator_class= (lib/watir-webdriver/elements/table_row.rb:27)
     Watir::TableSection#[] (lib/watir-webdriver/elements/table_section.rb:5)
     Watir::Window#== (lib/watir-webdriver/window_switching.rb:55)
     Watir::Window#eql? (lib/watir-webdriver/window_switching.rb:60)
     Watir::Window#hash (lib/watir-webdriver/window_switching.rb:62)
     Watir::WindowSwitching::NoMatchingWindowFoundException (lib/watir-webdriver/window_switching.rb:4)

   Modified objects:

     Watir::Browser#initialize (lib/watir-webdriver/browser.rb:31)
     Watir::Button.from (lib/watir-webdriver/elements/button.rb:16)
     Watir::Element#== (lib/watir-webdriver/elements/element.rb:44)
     Watir::Element#eql? (lib/watir-webdriver/elements/element.rb:48)
     Watir::ElementCollection#first (lib/watir-webdriver/element_collection.rb:55)
     Watir::ElementCollection#last (lib/watir-webdriver/element_collection.rb:65)
     Watir::ElementLocator#locate (lib/watir-webdriver/locators/element_locator.rb:26)
     Watir::Table#to_a (lib/watir-webdriver/elements/table.rb:11)
     Watir::TableRow#[] (lib/watir-webdriver/elements/table_row.rb:10)
     Watir::Window#use (lib/watir-webdriver/window_switching.rb:73)
     Watir::WindowSwitching#window (lib/watir-webdriver/window_switching.rb:16)
     Watir::WindowSwitching#windows (lib/watir-webdriver/window_switching.rb:4)

   Removed objects:

     Watir::ButtonLocator::VALID_TYPES (lib/watir-webdriver/locators/button_locator.rb:4)
     Watir::Container#cell (lib/watir-webdriver.rb:58)
     Watir::Container#cells (lib/watir-webdriver.rb:59)
     Watir::Container#row (lib/watir-webdriver.rb:60)
     Watir::Container#rows (lib/watir-webdriver.rb:61)
     Watir::Input#to_button (lib/watir-webdriver/elements/input.rb:70)
     Watir::Input#to_checkbox (lib/watir-webdriver/elements/input.rb:52)
     Watir::Input#to_file_field (lib/watir-webdriver/elements/input.rb:88)
     Watir::Input#to_radio (lib/watir-webdriver/elements/input.rb:61)
     Watir::Input#to_text_field (lib/watir-webdriver/elements/input.rb:79)
     Watir::Select#includes? (lib/watir-webdriver/elements/select.rb:47)
     Watir::TableRowLocator (lib/watir-webdriver/locators/table_row_locator.rb:2)
     Watir::TableRowLocator#locate_all (lib/watir-webdriver/locators/table_row_locator.rb:4)


### 0.0.9

   Added objects:

     Watir::CheckBoxCollection#element_class (lib/watir-webdriver/elements/checkbox.rb:69)

   Modified objects:

     Watir::WhenPresentDecorator#method_missing (lib/watir-webdriver/extensions/wait.rb:53)

   Removed objects:

     Watir::CheckBoxCollection#element_name (lib/watir-webdriver/elements/checkbox.rb:69)


### 0.0.8

   Added objects:

     Object (lib/watir-webdriver.rb:68)
     Watir::ButtonLocator::VALID_TYPES (lib/watir-webdriver/locators/button_locator.rb:4)
     Watir::Container#img (lib/watir-webdriver/elements/generated.rb:1592)
     Watir::Container#imgs (lib/watir-webdriver/elements/generated.rb:1600)
     Watir::Element#== (lib/watir-webdriver/elements/element.rb:44)
     Watir::Element#eql? (lib/watir-webdriver/elements/element.rb:48)
     Watir::Element#hash (lib/watir-webdriver/elements/element.rb:50)
     Watir::Element#present? (lib/watir-webdriver/extensions/wait.rb:70)
     Watir::Element#wait_until_present (lib/watir-webdriver/extensions/wait.rb:95)
     Watir::Element#wait_while_present (lib/watir-webdriver/extensions/wait.rb:99)
     Watir::Element#when_present (lib/watir-webdriver/extensions/wait.rb:86)
     Watir::FileField#value= (lib/watir-webdriver/elements/file_field.rb:30)
     Watir::Wait (lib/watir-webdriver/extensions/wait.rb:3)
     Watir::Wait.until (lib/watir-webdriver/extensions/wait.rb:13)
     Watir::Wait.while (lib/watir-webdriver/extensions/wait.rb:29)
     Watir::Wait::TimeoutError (lib/watir-webdriver/extensions/wait.rb:6)
     Watir::WhenPresentDecorator (lib/watir-webdriver/extensions/wait.rb:47)
     Watir::WhenPresentDecorator#initialize (lib/watir-webdriver/extensions/wait.rb:48)
     Watir::WhenPresentDecorator#method_missing (lib/watir-webdriver/extensions/wait.rb:53)
     Watir::Window (lib/watir-webdriver/window_switching.rb:41)
     Watir::Window#close (lib/watir-webdriver/window_switching.rb:55)
     Watir::Window#current? (lib/watir-webdriver/window_switching.rb:51)
     Watir::Window#initialize (lib/watir-webdriver/window_switching.rb:42)
     Watir::Window#inspect (lib/watir-webdriver/window_switching.rb:47)
     Watir::Window#title (lib/watir-webdriver/window_switching.rb:59)
     Watir::Window#url (lib/watir-webdriver/window_switching.rb:66)
     Watir::Window#use (lib/watir-webdriver/window_switching.rb:73)
     Watir::WindowSwitching (lib/watir-webdriver/window_switching.rb:2)
     Watir::WindowSwitching#window (lib/watir-webdriver/window_switching.rb:16)
     Watir::WindowSwitching#windows (lib/watir-webdriver/window_switching.rb:4)

   Modified objects:

     Watir::Browser#execute_script (lib/watir-webdriver/browser.rb:104)
     Watir::Browser#goto (lib/watir-webdriver/browser.rb:51)
     Watir::Browser#html (lib/watir-webdriver/browser.rb:91)
     Watir::Button#text (lib/watir-webdriver/elements/button.rb:31)
     Watir::Button.from (lib/watir-webdriver/elements/button.rb:16)
     Watir::Container#image (lib/watir-webdriver/elements/generated.rb:1592)
     Watir::Container#images (lib/watir-webdriver/elements/generated.rb:1600)
     Watir::Element#flash (lib/watir-webdriver/element.rb:72)
     Watir::Element#style (lib/watir-webdriver/element.rb:148)
     Watir::Element#value (lib/watir-webdriver/element.rb:81)
     Watir::ElementLocator#locate (lib/watir-webdriver/locators/element_locator.rb:26)
     Watir::FileField#set (lib/watir-webdriver/elements/file_field.rb:18)
     Watir::HTML::Util.paramify (lib/watir-webdriver/html/util.rb:20)
     Watir::Select#select (lib/watir-webdriver/elements/select.rb:58)
     Watir::Select#select_value (lib/watir-webdriver/elements/select.rb:72)

   Removed objects:

     Watir::Anchor#url (lib/watir-webdriver/elements/link.rb:4)
     Watir::ButtonLocator#build_xpath (lib/watir-webdriver/locators/button_locator.rb:8)
     Watir::ButtonLocator#lhs_for (lib/watir-webdriver/locators/button_locator.rb:30)
     Watir::ButtonLocator#matches_selector? (lib/watir-webdriver/locators/button_locator.rb:40)
     Watir::ButtonLocator#tag_name_matches? (lib/watir-webdriver/locators/button_locator.rb:53)
     Watir::ElementLocator#all_elements (lib/watir-webdriver/locators/element_locator.rb:234)
     Watir::ElementLocator#assert_valid_as_attribute (lib/watir-webdriver/locators/element_locator.rb:212)
     Watir::ElementLocator#attribute_expression (lib/watir-webdriver/locators/element_locator.rb:272)
     Watir::ElementLocator#build_xpath (lib/watir-webdriver/locators/element_locator.rb:250)
     Watir::ElementLocator#by_id (lib/watir-webdriver/locators/element_locator.rb:218)
     Watir::ElementLocator#check_type (lib/watir-webdriver/locators/element_locator.rb:141)
     Watir::ElementLocator#delete_regexps_from (lib/watir-webdriver/locators/element_locator.rb:200)
     Watir::ElementLocator#equal_pair (lib/watir-webdriver/locators/element_locator.rb:282)
     Watir::ElementLocator#fetch_value (lib/watir-webdriver/locators/element_locator.rb:152)
     Watir::ElementLocator#find_all_by_multiple (lib/watir-webdriver/locators/element_locator.rb:94)
     Watir::ElementLocator#find_all_by_one (lib/watir-webdriver/locators/element_locator.rb:60)
     Watir::ElementLocator#find_first_by_multiple (lib/watir-webdriver/locators/element_locator.rb:71)
     Watir::ElementLocator#find_first_by_one (lib/watir-webdriver/locators/element_locator.rb:49)
     Watir::ElementLocator#lhs_for (lib/watir-webdriver/locators/element_locator.rb:291)
     Watir::ElementLocator#matches_selector? (lib/watir-webdriver/locators/element_locator.rb:163)
     Watir::ElementLocator#normalize_selector (lib/watir-webdriver/locators/element_locator.rb:184)
     Watir::ElementLocator#normalized_selector (lib/watir-webdriver/locators/element_locator.rb:171)
     Watir::ElementLocator#should_use_label_element? (lib/watir-webdriver/locators/element_locator.rb:246)
     Watir::ElementLocator#tag_name_matches? (lib/watir-webdriver/locators/element_locator.rb:238)
     Watir::ElementLocator#valid_attribute? (lib/watir-webdriver/locators/element_locator.rb:242)
     Watir::ElementLocator#wd_find_all_by (lib/watir-webdriver/locators/element_locator.rb:117)
     Watir::ElementLocator#wd_find_by_regexp_selector (lib/watir-webdriver/locators/element_locator.rb:125)
     Watir::ElementLocator#wd_find_first_by (lib/watir-webdriver/locators/element_locator.rb:109)
     Watir::HTML::Util::SPECIALS (lib/watir-webdriver/html/util.rb:16)
     Watir::TableRowLocator#build_xpath (lib/watir-webdriver/locators/table_row_locator.rb:8)
     Watir::TextField#inspect (lib/watir-webdriver/elements/text_field.rb:21)
     Watir::TextField#type (lib/watir-webdriver/elements/text_field.rb:19)
     Watir::TextFieldLocator#build_xpath (lib/watir-webdriver/locators/text_field_locator.rb:12)
     Watir::TextFieldLocator#lhs_for (lib/watir-webdriver/locators/text_field_locator.rb:34)
     Watir::TextFieldLocator#matches_selector? (lib/watir-webdriver/locators/text_field_locator.rb:44)
     Watir::TextFieldLocator#tag_name_matches? (lib/watir-webdriver/locators/text_field_locator.rb:57)


### 0.0.7

   Added objects:

     Watir::Anchor#url (lib/watir-webdriver/elements/link.rb:4)
     Watir::AnchorCollection (lib/watir-webdriver/elements/generated.rb:349)
     Watir::AnchorCollection#element_class (lib/watir-webdriver/elements/generated.rb:350)
     Watir::AppletCollection (lib/watir-webdriver/elements/generated.rb:69)
     Watir::AppletCollection#element_class (lib/watir-webdriver/elements/generated.rb:70)
     Watir::AreaCollection (lib/watir-webdriver/elements/generated.rb:669)
     Watir::AreaCollection#element_class (lib/watir-webdriver/elements/generated.rb:670)
     Watir::AttributeHelper#attribute_list (lib/watir-webdriver/attribute_helper.rb:17)
     Watir::AttributeHelper#attributes (lib/watir-webdriver/attribute_helper.rb:26)
     Watir::AttributeHelper#typed_attributes (lib/watir-webdriver/attribute_helper.rb:13)
     Watir::AttributeHelper::IGNORED_ATTRIBUTES (lib/watir-webdriver/attribute_helper.rb:11)
     Watir::AudioCollection (lib/watir-webdriver/elements/generated.rb:249)
     Watir::AudioCollection#element_class (lib/watir-webdriver/elements/generated.rb:250)
     Watir::BRCollection (lib/watir-webdriver/elements/generated.rb:329)
     Watir::BRCollection#element_class (lib/watir-webdriver/elements/generated.rb:330)
     Watir::BaseCollection (lib/watir-webdriver/elements/generated.rb:477)
     Watir::BaseCollection#element_class (lib/watir-webdriver/elements/generated.rb:478)
     Watir::BaseFontCollection (lib/watir-webdriver/elements/generated.rb:749)
     Watir::BaseFontCollection#element_class (lib/watir-webdriver/elements/generated.rb:750)
     Watir::BodyCollection (lib/watir-webdriver/elements/generated.rb:433)
     Watir::BodyCollection#element_class (lib/watir-webdriver/elements/generated.rb:434)
     Watir::Button.from (lib/watir-webdriver/elements/button.rb:16)
     Watir::ButtonCollection (lib/watir-webdriver/elements/button.rb:62)
     Watir::ButtonCollection#element_class (lib/watir-webdriver/elements/generated.rb:704)
     Watir::CanvasCollection (lib/watir-webdriver/elements/generated.rb:569)
     Watir::CanvasCollection#element_class (lib/watir-webdriver/elements/generated.rb:570)
     Watir::CheckBox.from (lib/watir-webdriver/elements/checkbox.rb:5)
     Watir::CheckBoxCollection (lib/watir-webdriver/elements/checkbox.rb:68)
     Watir::CheckBoxCollection#element_name (lib/watir-webdriver/elements/checkbox.rb:69)
     Watir::CommandCollection (lib/watir-webdriver/elements/generated.rb:89)
     Watir::CommandCollection#element_class (lib/watir-webdriver/elements/generated.rb:90)
     Watir::Container#a (lib/watir-webdriver/elements/generated.rb:759)
     Watir::Container#abbr (lib/watir-webdriver/elements/generated.rb:776)
     Watir::Container#abbrs (lib/watir-webdriver/elements/generated.rb:784)
     Watir::Container#address (lib/watir-webdriver/elements/generated.rb:793)
     Watir::Container#addresses (lib/watir-webdriver/elements/generated.rb:801)
     Watir::Container#area (lib/watir-webdriver/elements/generated.rb:810)
     Watir::Container#areas (lib/watir-webdriver/elements/generated.rb:818)
     Watir::Container#article (lib/watir-webdriver/elements/generated.rb:827)
     Watir::Container#articles (lib/watir-webdriver/elements/generated.rb:835)
     Watir::Container#as (lib/watir-webdriver/elements/generated.rb:767)
     Watir::Container#aside (lib/watir-webdriver/elements/generated.rb:844)
     Watir::Container#asides (lib/watir-webdriver/elements/generated.rb:852)
     Watir::Container#audio (lib/watir-webdriver/elements/generated.rb:861)
     Watir::Container#audios (lib/watir-webdriver/elements/generated.rb:869)
     Watir::Container#b (lib/watir-webdriver/elements/generated.rb:878)
     Watir::Container#base (lib/watir-webdriver/elements/generated.rb:895)
     Watir::Container#bases (lib/watir-webdriver/elements/generated.rb:903)
     Watir::Container#bdo (lib/watir-webdriver/elements/generated.rb:912)
     Watir::Container#bdos (lib/watir-webdriver/elements/generated.rb:920)
     Watir::Container#blockquote (lib/watir-webdriver/elements/generated.rb:929)
     Watir::Container#blockquotes (lib/watir-webdriver/elements/generated.rb:937)
     Watir::Container#body (lib/watir-webdriver/elements/generated.rb:946)
     Watir::Container#bodys (lib/watir-webdriver/elements/generated.rb:954)
     Watir::Container#br (lib/watir-webdriver/elements/generated.rb:963)
     Watir::Container#brs (lib/watir-webdriver/elements/generated.rb:971)
     Watir::Container#bs (lib/watir-webdriver/elements/generated.rb:886)
     Watir::Container#button (lib/watir-webdriver/elements/generated.rb:980)
     Watir::Container#buttons (lib/watir-webdriver/elements/generated.rb:988)
     Watir::Container#canvas (lib/watir-webdriver/elements/generated.rb:997)
     Watir::Container#canvases (lib/watir-webdriver/elements/generated.rb:1005)
     Watir::Container#caption (lib/watir-webdriver/elements/generated.rb:1014)
     Watir::Container#captions (lib/watir-webdriver/elements/generated.rb:1022)
     Watir::Container#checkbox (lib/watir-webdriver/elements/checkbox.rb:59)
     Watir::Container#checkboxes (lib/watir-webdriver/elements/checkbox.rb:63)
     Watir::Container#cite (lib/watir-webdriver/elements/generated.rb:1031)
     Watir::Container#cites (lib/watir-webdriver/elements/generated.rb:1039)
     Watir::Container#code (lib/watir-webdriver/elements/generated.rb:1048)
     Watir::Container#codes (lib/watir-webdriver/elements/generated.rb:1056)
     Watir::Container#col (lib/watir-webdriver/elements/generated.rb:1065)
     Watir::Container#colgroup (lib/watir-webdriver/elements/generated.rb:1082)
     Watir::Container#colgroups (lib/watir-webdriver/elements/generated.rb:1090)
     Watir::Container#cols (lib/watir-webdriver/elements/generated.rb:1073)
     Watir::Container#command (lib/watir-webdriver/elements/generated.rb:1099)
     Watir::Container#commands (lib/watir-webdriver/elements/generated.rb:1107)
     Watir::Container#datalist (lib/watir-webdriver/elements/generated.rb:1116)
     Watir::Container#datalists (lib/watir-webdriver/elements/generated.rb:1124)
     Watir::Container#dd (lib/watir-webdriver/elements/generated.rb:1133)
     Watir::Container#dds (lib/watir-webdriver/elements/generated.rb:1141)
     Watir::Container#del (lib/watir-webdriver/elements/generated.rb:1150)
     Watir::Container#dels (lib/watir-webdriver/elements/generated.rb:1158)
     Watir::Container#details (lib/watir-webdriver/elements/generated.rb:1167)
     Watir::Container#dfn (lib/watir-webdriver/elements/generated.rb:1184)
     Watir::Container#dfns (lib/watir-webdriver/elements/generated.rb:1192)
     Watir::Container#div (lib/watir-webdriver/elements/generated.rb:1201)
     Watir::Container#divs (lib/watir-webdriver/elements/generated.rb:1209)
     Watir::Container#dl (lib/watir-webdriver/elements/generated.rb:1218)
     Watir::Container#dls (lib/watir-webdriver/elements/generated.rb:1226)
     Watir::Container#dt (lib/watir-webdriver/elements/generated.rb:1235)
     Watir::Container#dts (lib/watir-webdriver/elements/generated.rb:1243)
     Watir::Container#em (lib/watir-webdriver/elements/generated.rb:1252)
     Watir::Container#embed (lib/watir-webdriver/elements/generated.rb:1269)
     Watir::Container#embeds (lib/watir-webdriver/elements/generated.rb:1277)
     Watir::Container#ems (lib/watir-webdriver/elements/generated.rb:1260)
     Watir::Container#fieldset (lib/watir-webdriver/elements/generated.rb:1286)
     Watir::Container#fieldsets (lib/watir-webdriver/elements/generated.rb:1294)
     Watir::Container#figcaption (lib/watir-webdriver/elements/generated.rb:1303)
     Watir::Container#figcaptions (lib/watir-webdriver/elements/generated.rb:1311)
     Watir::Container#figure (lib/watir-webdriver/elements/generated.rb:1320)
     Watir::Container#figures (lib/watir-webdriver/elements/generated.rb:1328)
     Watir::Container#file_field (lib/watir-webdriver/elements/file_field.rb:38)
     Watir::Container#file_fields (lib/watir-webdriver/elements/file_field.rb:42)
     Watir::Container#font (lib/watir-webdriver/elements/font.rb:3)
     Watir::Container#fonts (lib/watir-webdriver/elements/font.rb:7)
     Watir::Container#footer (lib/watir-webdriver/elements/generated.rb:1337)
     Watir::Container#footers (lib/watir-webdriver/elements/generated.rb:1345)
     Watir::Container#form (lib/watir-webdriver/elements/generated.rb:1354)
     Watir::Container#forms (lib/watir-webdriver/elements/generated.rb:1362)
     Watir::Container#frame (lib/watir-webdriver/elements/frame.rb:102)
     Watir::Container#frames (lib/watir-webdriver/elements/frame.rb:106)
     Watir::Container#h1 (lib/watir-webdriver/elements/generated.rb:1371)
     Watir::Container#h1s (lib/watir-webdriver/elements/generated.rb:1379)
     Watir::Container#h2 (lib/watir-webdriver/elements/generated.rb:1388)
     Watir::Container#h2s (lib/watir-webdriver/elements/generated.rb:1396)
     Watir::Container#h3 (lib/watir-webdriver/elements/generated.rb:1405)
     Watir::Container#h3s (lib/watir-webdriver/elements/generated.rb:1413)
     Watir::Container#h4 (lib/watir-webdriver/elements/generated.rb:1422)
     Watir::Container#h4s (lib/watir-webdriver/elements/generated.rb:1430)
     Watir::Container#h5 (lib/watir-webdriver/elements/generated.rb:1439)
     Watir::Container#h5s (lib/watir-webdriver/elements/generated.rb:1447)
     Watir::Container#h6 (lib/watir-webdriver/elements/generated.rb:1456)
     Watir::Container#h6s (lib/watir-webdriver/elements/generated.rb:1464)
     Watir::Container#head (lib/watir-webdriver/elements/generated.rb:1473)
     Watir::Container#header (lib/watir-webdriver/elements/generated.rb:1490)
     Watir::Container#headers (lib/watir-webdriver/elements/generated.rb:1498)
     Watir::Container#heads (lib/watir-webdriver/elements/generated.rb:1481)
     Watir::Container#hgroup (lib/watir-webdriver/elements/generated.rb:1507)
     Watir::Container#hgroups (lib/watir-webdriver/elements/generated.rb:1515)
     Watir::Container#hidden (lib/watir-webdriver/elements/hidden.rb:10)
     Watir::Container#hiddens (lib/watir-webdriver/elements/hidden.rb:14)
     Watir::Container#hr (lib/watir-webdriver/elements/generated.rb:1524)
     Watir::Container#hrs (lib/watir-webdriver/elements/generated.rb:1532)
     Watir::Container#html (lib/watir-webdriver/elements/generated.rb:1541)
     Watir::Container#htmls (lib/watir-webdriver/elements/generated.rb:1549)
     Watir::Container#i (lib/watir-webdriver/elements/generated.rb:1558)
     Watir::Container#iframe (lib/watir-webdriver/elements/generated.rb:1575)
     Watir::Container#iframes (lib/watir-webdriver/elements/generated.rb:1583)
     Watir::Container#image (lib/watir-webdriver/elements/generated.rb:1592)
     Watir::Container#images (lib/watir-webdriver/elements/generated.rb:1600)
     Watir::Container#input (lib/watir-webdriver/elements/generated.rb:1609)
     Watir::Container#inputs (lib/watir-webdriver/elements/generated.rb:1617)
     Watir::Container#ins (lib/watir-webdriver/elements/generated.rb:1626)
     Watir::Container#inses (lib/watir-webdriver/elements/generated.rb:1634)
     Watir::Container#is (lib/watir-webdriver/elements/generated.rb:1566)
     Watir::Container#kbd (lib/watir-webdriver/elements/generated.rb:1643)
     Watir::Container#kbds (lib/watir-webdriver/elements/generated.rb:1651)
     Watir::Container#keygen (lib/watir-webdriver/elements/generated.rb:1660)
     Watir::Container#keygens (lib/watir-webdriver/elements/generated.rb:1668)
     Watir::Container#label (lib/watir-webdriver/elements/generated.rb:1677)
     Watir::Container#labels (lib/watir-webdriver/elements/generated.rb:1685)
     Watir::Container#legend (lib/watir-webdriver/elements/generated.rb:1694)
     Watir::Container#legends (lib/watir-webdriver/elements/generated.rb:1702)
     Watir::Container#li (lib/watir-webdriver/elements/generated.rb:1711)
     Watir::Container#link (lib/watir-webdriver/elements/link.rb:8)
     Watir::Container#links (lib/watir-webdriver/elements/link.rb:9)
     Watir::Container#lis (lib/watir-webdriver/elements/generated.rb:1719)
     Watir::Container#map (lib/watir-webdriver/elements/generated.rb:1728)
     Watir::Container#maps (lib/watir-webdriver/elements/generated.rb:1736)
     Watir::Container#mark (lib/watir-webdriver/elements/generated.rb:1745)
     Watir::Container#marks (lib/watir-webdriver/elements/generated.rb:1753)
     Watir::Container#menu (lib/watir-webdriver/elements/generated.rb:1762)
     Watir::Container#menus (lib/watir-webdriver/elements/generated.rb:1770)
     Watir::Container#meta (lib/watir-webdriver/elements/generated.rb:1779)
     Watir::Container#metas (lib/watir-webdriver/elements/generated.rb:1787)
     Watir::Container#meter (lib/watir-webdriver/elements/generated.rb:1796)
     Watir::Container#meters (lib/watir-webdriver/elements/generated.rb:1804)
     Watir::Container#nav (lib/watir-webdriver/elements/generated.rb:1813)
     Watir::Container#navs (lib/watir-webdriver/elements/generated.rb:1821)
     Watir::Container#noscript (lib/watir-webdriver/elements/generated.rb:1830)
     Watir::Container#noscripts (lib/watir-webdriver/elements/generated.rb:1838)
     Watir::Container#object (lib/watir-webdriver/elements/generated.rb:1847)
     Watir::Container#objects (lib/watir-webdriver/elements/generated.rb:1855)
     Watir::Container#ol (lib/watir-webdriver/elements/generated.rb:1864)
     Watir::Container#ols (lib/watir-webdriver/elements/generated.rb:1872)
     Watir::Container#optgroup (lib/watir-webdriver/elements/generated.rb:1881)
     Watir::Container#optgroups (lib/watir-webdriver/elements/generated.rb:1889)
     Watir::Container#option (lib/watir-webdriver/elements/generated.rb:1898)
     Watir::Container#options (lib/watir-webdriver/elements/generated.rb:1906)
     Watir::Container#output (lib/watir-webdriver/elements/generated.rb:1915)
     Watir::Container#outputs (lib/watir-webdriver/elements/generated.rb:1923)
     Watir::Container#p (lib/watir-webdriver/elements/generated.rb:1932)
     Watir::Container#param (lib/watir-webdriver/elements/generated.rb:1949)
     Watir::Container#params (lib/watir-webdriver/elements/generated.rb:1957)
     Watir::Container#pre (lib/watir-webdriver/elements/generated.rb:1966)
     Watir::Container#pres (lib/watir-webdriver/elements/generated.rb:1974)
     Watir::Container#progress (lib/watir-webdriver/elements/generated.rb:1983)
     Watir::Container#progresses (lib/watir-webdriver/elements/generated.rb:1991)
     Watir::Container#ps (lib/watir-webdriver/elements/generated.rb:1940)
     Watir::Container#q (lib/watir-webdriver/elements/generated.rb:2000)
     Watir::Container#qs (lib/watir-webdriver/elements/generated.rb:2008)
     Watir::Container#radio (lib/watir-webdriver/elements/radio.rb:33)
     Watir::Container#radios (lib/watir-webdriver/elements/radio.rb:37)
     Watir::Container#rp (lib/watir-webdriver/elements/generated.rb:2017)
     Watir::Container#rps (lib/watir-webdriver/elements/generated.rb:2025)
     Watir::Container#rt (lib/watir-webdriver/elements/generated.rb:2034)
     Watir::Container#rts (lib/watir-webdriver/elements/generated.rb:2042)
     Watir::Container#rubies (lib/watir-webdriver/elements/generated.rb:2059)
     Watir::Container#ruby (lib/watir-webdriver/elements/generated.rb:2051)
     Watir::Container#samp (lib/watir-webdriver/elements/generated.rb:2068)
     Watir::Container#samps (lib/watir-webdriver/elements/generated.rb:2076)
     Watir::Container#script (lib/watir-webdriver/elements/generated.rb:2085)
     Watir::Container#scripts (lib/watir-webdriver/elements/generated.rb:2093)
     Watir::Container#section (lib/watir-webdriver/elements/generated.rb:2102)
     Watir::Container#sections (lib/watir-webdriver/elements/generated.rb:2110)
     Watir::Container#select (lib/watir-webdriver/elements/generated.rb:2119)
     Watir::Container#select_list (lib/watir-webdriver/elements/select.rb:216)
     Watir::Container#select_lists (lib/watir-webdriver/elements/select.rb:217)
     Watir::Container#selects (lib/watir-webdriver/elements/generated.rb:2127)
     Watir::Container#small (lib/watir-webdriver/elements/generated.rb:2136)
     Watir::Container#smalls (lib/watir-webdriver/elements/generated.rb:2144)
     Watir::Container#source (lib/watir-webdriver/elements/generated.rb:2153)
     Watir::Container#sources (lib/watir-webdriver/elements/generated.rb:2161)
     Watir::Container#span (lib/watir-webdriver/elements/generated.rb:2170)
     Watir::Container#spans (lib/watir-webdriver/elements/generated.rb:2178)
     Watir::Container#strong (lib/watir-webdriver/elements/generated.rb:2187)
     Watir::Container#strongs (lib/watir-webdriver/elements/generated.rb:2195)
     Watir::Container#style (lib/watir-webdriver/elements/generated.rb:2204)
     Watir::Container#styles (lib/watir-webdriver/elements/generated.rb:2212)
     Watir::Container#sub (lib/watir-webdriver/elements/generated.rb:2221)
     Watir::Container#subs (lib/watir-webdriver/elements/generated.rb:2229)
     Watir::Container#summaries (lib/watir-webdriver/elements/generated.rb:2246)
     Watir::Container#summary (lib/watir-webdriver/elements/generated.rb:2238)
     Watir::Container#sup (lib/watir-webdriver/elements/generated.rb:2255)
     Watir::Container#sups (lib/watir-webdriver/elements/generated.rb:2263)
     Watir::Container#table (lib/watir-webdriver/elements/generated.rb:2272)
     Watir::Container#tables (lib/watir-webdriver/elements/generated.rb:2280)
     Watir::Container#tbody (lib/watir-webdriver/elements/generated.rb:2289)
     Watir::Container#tbodys (lib/watir-webdriver/elements/generated.rb:2297)
     Watir::Container#td (lib/watir-webdriver/elements/generated.rb:2306)
     Watir::Container#tds (lib/watir-webdriver/elements/generated.rb:2314)
     Watir::Container#text_field (lib/watir-webdriver/elements/text_field.rb:87)
     Watir::Container#text_fields (lib/watir-webdriver/elements/text_field.rb:91)
     Watir::Container#textarea (lib/watir-webdriver/elements/generated.rb:2323)
     Watir::Container#textareas (lib/watir-webdriver/elements/generated.rb:2331)
     Watir::Container#tfoot (lib/watir-webdriver/elements/generated.rb:2340)
     Watir::Container#tfoots (lib/watir-webdriver/elements/generated.rb:2348)
     Watir::Container#th (lib/watir-webdriver/elements/generated.rb:2357)
     Watir::Container#thead (lib/watir-webdriver/elements/generated.rb:2374)
     Watir::Container#theads (lib/watir-webdriver/elements/generated.rb:2382)
     Watir::Container#ths (lib/watir-webdriver/elements/generated.rb:2365)
     Watir::Container#time (lib/watir-webdriver/elements/generated.rb:2391)
     Watir::Container#times (lib/watir-webdriver/elements/generated.rb:2399)
     Watir::Container#title (lib/watir-webdriver/elements/generated.rb:2408)
     Watir::Container#titles (lib/watir-webdriver/elements/generated.rb:2416)
     Watir::Container#tr (lib/watir-webdriver/elements/generated.rb:2425)
     Watir::Container#track (lib/watir-webdriver/elements/generated.rb:2442)
     Watir::Container#tracks (lib/watir-webdriver/elements/generated.rb:2450)
     Watir::Container#trs (lib/watir-webdriver/elements/generated.rb:2433)
     Watir::Container#ul (lib/watir-webdriver/elements/generated.rb:2459)
     Watir::Container#uls (lib/watir-webdriver/elements/generated.rb:2467)
     Watir::Container#var (lib/watir-webdriver/elements/generated.rb:2476)
     Watir::Container#vars (lib/watir-webdriver/elements/generated.rb:2484)
     Watir::Container#video (lib/watir-webdriver/elements/generated.rb:2493)
     Watir::Container#videos (lib/watir-webdriver/elements/generated.rb:2501)
     Watir::Container#wbr (lib/watir-webdriver/elements/generated.rb:2510)
     Watir::Container#wbrs (lib/watir-webdriver/elements/generated.rb:2518)
     Watir::DListCollection (lib/watir-webdriver/elements/generated.rb:361)
     Watir::DListCollection#element_class (lib/watir-webdriver/elements/generated.rb:362)
     Watir::DataListCollection (lib/watir-webdriver/elements/generated.rb:137)
     Watir::DataListCollection#element_class (lib/watir-webdriver/elements/generated.rb:138)
     Watir::DetailsCollection (lib/watir-webdriver/elements/generated.rb:739)
     Watir::DetailsCollection#element_class (lib/watir-webdriver/elements/generated.rb:740)
     Watir::Device (lib/watir-webdriver/elements/generated.rb:623)
     Watir::DeviceCollection (lib/watir-webdriver/elements/generated.rb:626)
     Watir::DeviceCollection#element_class (lib/watir-webdriver/elements/generated.rb:627)
     Watir::DirectoryCollection (lib/watir-webdriver/elements/generated.rb:45)
     Watir::DirectoryCollection#element_class (lib/watir-webdriver/elements/generated.rb:46)
     Watir::DivCollection (lib/watir-webdriver/elements/generated.rb:613)
     Watir::DivCollection#element_class (lib/watir-webdriver/elements/generated.rb:614)
     Watir::Element (lib/watir-webdriver/element.rb:4)
     Watir::Element#attribute_value (lib/watir-webdriver/element.rb:91)
     Watir::Element#click (lib/watir-webdriver/element.rb:49)
     Watir::Element#double_click (lib/watir-webdriver/element.rb:56)
     Watir::Element#driver (lib/watir-webdriver/element.rb:133)
     Watir::Element#element (lib/watir-webdriver/element.rb:137)
     Watir::Element#exist? (lib/watir-webdriver/element.rb:29)
     Watir::Element#exists? (lib/watir-webdriver/element.rb:23)
     Watir::Element#fire_event (lib/watir-webdriver/element.rb:117)
     Watir::Element#flash (lib/watir-webdriver/element.rb:72)
     Watir::Element#focus (lib/watir-webdriver/element.rb:112)
     Watir::Element#html (lib/watir-webdriver/element.rb:96)
     Watir::Element#initialize (lib/watir-webdriver/element.rb:10)
     Watir::Element#inspect (lib/watir-webdriver/element.rb:31)
     Watir::Element#parent (lib/watir-webdriver/element.rb:123)
     Watir::Element#right_click (lib/watir-webdriver/element.rb:64)
     Watir::Element#run_checkers (lib/watir-webdriver/element.rb:157)
     Watir::Element#send_keys (lib/watir-webdriver/element.rb:101)
     Watir::Element#style (lib/watir-webdriver/element.rb:148)
     Watir::Element#tag_name (lib/watir-webdriver/element.rb:44)
     Watir::Element#text (lib/watir-webdriver/element.rb:39)
     Watir::Element#value (lib/watir-webdriver/element.rb:81)
     Watir::Element#visible? (lib/watir-webdriver/element.rb:143)
     Watir::Element#wd (lib/watir-webdriver/element.rb:141)
     Watir::ElementLocator#all_elements (lib/watir-webdriver/locators/element_locator.rb:234)
     Watir::EmbedCollection (lib/watir-webdriver/elements/generated.rb:654)
     Watir::EmbedCollection#element_class (lib/watir-webdriver/elements/generated.rb:655)
     Watir::FieldSetCollection (lib/watir-webdriver/elements/generated.rb:731)
     Watir::FieldSetCollection#element_class (lib/watir-webdriver/elements/generated.rb:732)
     Watir::FileField.from (lib/watir-webdriver/elements/file_field.rb:4)
     Watir::FileFieldCollection (lib/watir-webdriver/elements/file_field.rb:47)
     Watir::FileFieldCollection#element_class (lib/watir-webdriver/elements/file_field.rb:48)
     Watir::FontCollection (lib/watir-webdriver/elements/generated.rb:514)
     Watir::FontCollection#element_class (lib/watir-webdriver/elements/generated.rb:515)
     Watir::FormCollection (lib/watir-webdriver/elements/generated.rb:177)
     Watir::FormCollection#element_class (lib/watir-webdriver/elements/generated.rb:178)
     Watir::FrameCollection (lib/watir-webdriver/elements/generated.rb:53)
     Watir::FrameCollection#element_class (lib/watir-webdriver/elements/generated.rb:54)
     Watir::FrameSetCollection (lib/watir-webdriver/elements/generated.rb:61)
     Watir::FrameSetCollection#element_class (lib/watir-webdriver/elements/generated.rb:62)
     Watir::HRCollection (lib/watir-webdriver/elements/generated.rb:397)
     Watir::HRCollection#element_class (lib/watir-webdriver/elements/generated.rb:398)
     Watir::HTML (lib/watir-webdriver/html/util.rb:2)
     Watir::HTML::Generator (lib/watir-webdriver/html/generator.rb:5)
     Watir::HTML::Generator#generate (lib/watir-webdriver/html/generator.rb:7)
     Watir::HTML::IDLSorter (lib/watir-webdriver/html/idl_sorter.rb:7)
     Watir::HTML::IDLSorter#initialize (lib/watir-webdriver/html/idl_sorter.rb:10)
     Watir::HTML::IDLSorter#print (lib/watir-webdriver/html/idl_sorter.rb:21)
     Watir::HTML::IDLSorter#sort (lib/watir-webdriver/html/idl_sorter.rb:26)
     Watir::HTML::IDLSorter#tsort_each_child (lib/watir-webdriver/html/idl_sorter.rb:34)
     Watir::HTML::IDLSorter#tsort_each_node (lib/watir-webdriver/html/idl_sorter.rb:30)
     Watir::HTML::SpecExtractor (lib/watir-webdriver/html/spec_extractor.rb:5)
     Watir::HTML::SpecExtractor#errors (lib/watir-webdriver/html/spec_extractor.rb:17)
     Watir::HTML::SpecExtractor#initialize (lib/watir-webdriver/html/spec_extractor.rb:6)
     Watir::HTML::SpecExtractor#print_hierarchy (lib/watir-webdriver/html/spec_extractor.rb:33)
     Watir::HTML::SpecExtractor#process (lib/watir-webdriver/html/spec_extractor.rb:10)
     Watir::HTML::SpecExtractor#sorted_interfaces (lib/watir-webdriver/html/spec_extractor.rb:25)
     Watir::HTML::Util (lib/watir-webdriver/html/util.rb:3)
     Watir::HTML::Util.classify (lib/watir-webdriver/html/util.rb:8)
     Watir::HTML::Util.paramify (lib/watir-webdriver/html/util.rb:20)
     Watir::HTML::Util::SPECIALS (lib/watir-webdriver/html/util.rb:16)
     Watir::HTML::Visitor (lib/watir-webdriver/html/visitor.rb:5)
     Watir::HTML::Visitor#initialize (lib/watir-webdriver/html/visitor.rb:7)
     Watir::HTML::Visitor#visit_implements_statement (lib/watir-webdriver/html/visitor.rb:49)
     Watir::HTML::Visitor#visit_interface (lib/watir-webdriver/html/visitor.rb:21)
     Watir::HTML::Visitor#visit_module (lib/watir-webdriver/html/visitor.rb:45)
     Watir::HTMLElementCollection (lib/watir-webdriver/elements/generated.rb:37)
     Watir::HTMLElementCollection#element_class (lib/watir-webdriver/elements/generated.rb:38)
     Watir::HeadCollection (lib/watir-webdriver/elements/generated.rb:485)
     Watir::HeadCollection#element_class (lib/watir-webdriver/elements/generated.rb:486)
     Watir::HeadingCollection (lib/watir-webdriver/elements/generated.rb:421)
     Watir::HeadingCollection#element_class (lib/watir-webdriver/elements/generated.rb:422)
     Watir::HiddenCollection (lib/watir-webdriver/elements/hidden.rb:19)
     Watir::HiddenCollection#element_class (lib/watir-webdriver/elements/hidden.rb:20)
     Watir::HtmlCollection (lib/watir-webdriver/elements/generated.rb:711)
     Watir::HtmlCollection#element_class (lib/watir-webdriver/elements/generated.rb:712)
     Watir::IFrameCollection (lib/watir-webdriver/elements/generated.rb:297)
     Watir::IFrameCollection#element_class (lib/watir-webdriver/elements/generated.rb:298)
     Watir::ImageCollection (lib/watir-webdriver/elements/generated.rb:309)
     Watir::ImageCollection#element_class (lib/watir-webdriver/elements/generated.rb:310)
     Watir::Input#to_file_field (lib/watir-webdriver/elements/input.rb:88)
     Watir::Input#to_text_field (lib/watir-webdriver/elements/input.rb:79)
     Watir::InputCollection (lib/watir-webdriver/elements/generated.rb:145)
     Watir::InputCollection#element_class (lib/watir-webdriver/elements/generated.rb:146)
     Watir::KeygenCollection (lib/watir-webdriver/elements/generated.rb:113)
     Watir::KeygenCollection#element_class (lib/watir-webdriver/elements/generated.rb:114)
     Watir::LICollection (lib/watir-webdriver/elements/generated.rb:373)
     Watir::LICollection#element_class (lib/watir-webdriver/elements/generated.rb:374)
     Watir::LabelCollection (lib/watir-webdriver/elements/generated.rb:157)
     Watir::LabelCollection#element_class (lib/watir-webdriver/elements/generated.rb:158)
     Watir::LegendCollection (lib/watir-webdriver/elements/generated.rb:165)
     Watir::LegendCollection#element_class (lib/watir-webdriver/elements/generated.rb:166)
     Watir::MapCollection (lib/watir-webdriver/elements/generated.rb:233)
     Watir::MapCollection#element_class (lib/watir-webdriver/elements/generated.rb:234)
     Watir::MarqueeCollection (lib/watir-webdriver/elements/generated.rb:506)
     Watir::MarqueeCollection#element_class (lib/watir-webdriver/elements/generated.rb:507)
     Watir::MediaCollection (lib/watir-webdriver/elements/generated.rb:241)
     Watir::MediaCollection#element_class (lib/watir-webdriver/elements/generated.rb:242)
     Watir::MenuCollection (lib/watir-webdriver/elements/generated.rb:77)
     Watir::MenuCollection#element_class (lib/watir-webdriver/elements/generated.rb:78)
     Watir::MetaCollection (lib/watir-webdriver/elements/generated.rb:465)
     Watir::MetaCollection#element_class (lib/watir-webdriver/elements/generated.rb:466)
     Watir::MeterCollection (lib/watir-webdriver/elements/generated.rb:97)
     Watir::MeterCollection#element_class (lib/watir-webdriver/elements/generated.rb:98)
     Watir::ModCollection (lib/watir-webdriver/elements/generated.rb:321)
     Watir::ModCollection#element_class (lib/watir-webdriver/elements/generated.rb:322)
     Watir::OListCollection (lib/watir-webdriver/elements/generated.rb:682)
     Watir::OListCollection#element_class (lib/watir-webdriver/elements/generated.rb:683)
     Watir::ObjectCollection (lib/watir-webdriver/elements/generated.rb:285)
     Watir::ObjectCollection#element_class (lib/watir-webdriver/elements/generated.rb:286)
     Watir::OptGroupCollection (lib/watir-webdriver/elements/generated.rb:561)
     Watir::OptGroupCollection#element_class (lib/watir-webdriver/elements/generated.rb:562)
     Watir::OptionCollection (lib/watir-webdriver/elements/generated.rb:129)
     Watir::OptionCollection#element_class (lib/watir-webdriver/elements/generated.rb:130)
     Watir::OutputCollection (lib/watir-webdriver/elements/generated.rb:636)
     Watir::OutputCollection#element_class (lib/watir-webdriver/elements/generated.rb:637)
     Watir::ParagraphCollection (lib/watir-webdriver/elements/generated.rb:409)
     Watir::ParagraphCollection#element_class (lib/watir-webdriver/elements/generated.rb:410)
     Watir::ParamCollection (lib/watir-webdriver/elements/generated.rb:273)
     Watir::ParamCollection#element_class (lib/watir-webdriver/elements/generated.rb:274)
     Watir::PreCollection (lib/watir-webdriver/elements/generated.rb:385)
     Watir::PreCollection#element_class (lib/watir-webdriver/elements/generated.rb:386)
     Watir::ProgressCollection (lib/watir-webdriver/elements/generated.rb:105)
     Watir::ProgressCollection#element_class (lib/watir-webdriver/elements/generated.rb:106)
     Watir::QuoteCollection (lib/watir-webdriver/elements/generated.rb:605)
     Watir::QuoteCollection#element_class (lib/watir-webdriver/elements/generated.rb:606)
     Watir::Radio.from (lib/watir-webdriver/elements/radio.rb:4)
     Watir::RadioCollection (lib/watir-webdriver/elements/radio.rb:42)
     Watir::ScriptCollection (lib/watir-webdriver/elements/generated.rb:445)
     Watir::ScriptCollection#element_class (lib/watir-webdriver/elements/generated.rb:446)
     Watir::Select#clear (lib/watir-webdriver/elements/select.rb:20)
     Watir::Select#enabled? (lib/watir-webdriver/elements/select.rb:12)
     Watir::Select#include? (lib/watir-webdriver/elements/select.rb:42)
     Watir::Select#includes? (lib/watir-webdriver/elements/select.rb:47)
     Watir::Select#options (lib/watir-webdriver/elements/select.rb:30)
     Watir::Select#select (lib/watir-webdriver/elements/select.rb:58)
     Watir::Select#select_value (lib/watir-webdriver/elements/select.rb:72)
     Watir::Select#selected? (lib/watir-webdriver/elements/select.rb:84)
     Watir::Select#selected_options (lib/watir-webdriver/elements/select.rb:112)
     Watir::Select#value (lib/watir-webdriver/elements/select.rb:102)
     Watir::SelectCollection (lib/watir-webdriver/elements/generated.rb:540)
     Watir::SelectCollection#element_class (lib/watir-webdriver/elements/generated.rb:541)
     Watir::SourceCollection (lib/watir-webdriver/elements/generated.rb:265)
     Watir::SourceCollection#element_class (lib/watir-webdriver/elements/generated.rb:266)
     Watir::SpanCollection (lib/watir-webdriver/elements/generated.rb:341)
     Watir::SpanCollection#element_class (lib/watir-webdriver/elements/generated.rb:342)
     Watir::StyleCollection (lib/watir-webdriver/elements/generated.rb:457)
     Watir::StyleCollection#element_class (lib/watir-webdriver/elements/generated.rb:458)
     Watir::TableCaptionCollection (lib/watir-webdriver/elements/generated.rb:522)
     Watir::TableCaptionCollection#element_class (lib/watir-webdriver/elements/generated.rb:523)
     Watir::TableCellCollection (lib/watir-webdriver/elements/generated.rb:577)
     Watir::TableCellCollection#element_class (lib/watir-webdriver/elements/generated.rb:578)
     Watir::TableColCollection (lib/watir-webdriver/elements/generated.rb:209)
     Watir::TableColCollection#element_class (lib/watir-webdriver/elements/generated.rb:210)
     Watir::TableCollection (lib/watir-webdriver/elements/generated.rb:221)
     Watir::TableCollection#element_class (lib/watir-webdriver/elements/generated.rb:222)
     Watir::TableDataCellCollection (lib/watir-webdriver/elements/generated.rb:597)
     Watir::TableDataCellCollection#element_class (lib/watir-webdriver/elements/generated.rb:598)
     Watir::TableHeaderCellCollection (lib/watir-webdriver/elements/generated.rb:589)
     Watir::TableHeaderCellCollection#element_class (lib/watir-webdriver/elements/generated.rb:590)
     Watir::TableRowCollection (lib/watir-webdriver/elements/generated.rb:185)
     Watir::TableRowCollection#element_class (lib/watir-webdriver/elements/generated.rb:186)
     Watir::TableSectionCollection (lib/watir-webdriver/elements/generated.rb:197)
     Watir::TableSectionCollection#element_class (lib/watir-webdriver/elements/generated.rb:198)
     Watir::TextAreaCollection (lib/watir-webdriver/elements/generated.rb:121)
     Watir::TextAreaCollection#element_class (lib/watir-webdriver/elements/generated.rb:122)
     Watir::TextField.from (lib/watir-webdriver/elements/text_field.rb:7)
     Watir::TextFieldCollection (lib/watir-webdriver/elements/text_field.rb:96)
     Watir::TimeCollection (lib/watir-webdriver/elements/generated.rb:494)
     Watir::TimeCollection#element_class (lib/watir-webdriver/elements/generated.rb:495)
     Watir::TitleCollection (lib/watir-webdriver/elements/generated.rb:723)
     Watir::TitleCollection#element_class (lib/watir-webdriver/elements/generated.rb:724)
     Watir::Track (lib/watir-webdriver/elements/generated.rb:641)
     Watir::TrackCollection (lib/watir-webdriver/elements/generated.rb:644)
     Watir::TrackCollection#element_class (lib/watir-webdriver/elements/generated.rb:645)
     Watir::UListCollection (lib/watir-webdriver/elements/generated.rb:548)
     Watir::UListCollection#element_class (lib/watir-webdriver/elements/generated.rb:549)
     Watir::Unknown (lib/watir-webdriver/elements/generated.rb:692)
     Watir::UnknownCollection (lib/watir-webdriver/elements/generated.rb:695)
     Watir::UnknownCollection#element_class (lib/watir-webdriver/elements/generated.rb:696)
     Watir::VideoCollection (lib/watir-webdriver/elements/generated.rb:257)
     Watir::VideoCollection#element_class (lib/watir-webdriver/elements/generated.rb:258)
     YARD (lib/yard/handlers/watir.rb:3)
     YARD::Handlers (lib/yard/handlers/watir.rb:4)
     YARD::Handlers::Watir (lib/yard/handlers/watir.rb:5)
     YARD::Handlers::Watir::AttributesHandler#process (lib/yard/handlers/watir.rb:19)
     YARD::Handlers::Watir::AttributesHandler::TYPES (lib/yard/handlers/watir.rb:13)

   Modified objects:

     Watir.element_class_for (lib/watir-webdriver.rb:23)
     Watir::Browser#close (lib/watir-webdriver/browser.rb:75)
     Watir::Browser#execute_script (lib/watir-webdriver/browser.rb:101)
     Watir::Browser#exist? (lib/watir-webdriver/browser.rb:141)
     Watir::Browser#initialize (lib/watir-webdriver/browser.rb:25)
     Watir::Browser#quit (lib/watir-webdriver/browser.rb:78)
     Watir::ElementCollection#[] (lib/watir-webdriver/collections/element_collection.rb:39)
     Watir::ElementCollection#first (lib/watir-webdriver/collections/element_collection.rb:49)
     Watir::ElementCollection#initialize (lib/watir-webdriver/collections/element_collection.rb:6)
     Watir::ElementCollection#last (lib/watir-webdriver/collections/element_collection.rb:59)
     Watir::ElementCollection#to_a (lib/watir-webdriver/collections/element_collection.rb:69)
     Watir::FileField#set (lib/watir-webdriver/elements/file_field.rb:15)
     Watir::Frame#assert_exists (lib/watir-webdriver/elements/frame.rb:26)
     Watir::Input#to_button (lib/watir-webdriver/elements/input.rb:44)
     Watir::Input#to_checkbox (lib/watir-webdriver/elements/input.rb:34)
     Watir::Input#to_radio (lib/watir-webdriver/elements/input.rb:39)
     Watir::TextFieldLocator#build_xpath (lib/watir-webdriver/locators/text_field_locator.rb:12)
     Watir::XpathSupport#element_by_xpath (lib/watir-webdriver/xpath_support.rb:10)
     Watir::XpathSupport#elements_by_xpath (lib/watir-webdriver/xpath_support.rb:21)

   Removed objects:

     Watir::Abbr (lib/watir-webdriver/elements/generated.rb:1277)
     Watir::Address (lib/watir-webdriver/elements/generated.rb:997)
     Watir::Article (lib/watir-webdriver/elements/generated.rb:1317)
     Watir::Aside (lib/watir-webdriver/elements/generated.rb:1207)
     Watir::B (lib/watir-webdriver/elements/generated.rb:1127)
     Watir::BaseElement (lib/watir-webdriver/base_element.rb:4)
     Watir::BaseElement#attribute_value (lib/watir-webdriver/base_element.rb:236)
     Watir::BaseElement#click (lib/watir-webdriver/base_element.rb:194)
     Watir::BaseElement#double_click (lib/watir-webdriver/base_element.rb:201)
     Watir::BaseElement#driver (lib/watir-webdriver/base_element.rb:278)
     Watir::BaseElement#element (lib/watir-webdriver/base_element.rb:282)
     Watir::BaseElement#exist? (lib/watir-webdriver/base_element.rb:174)
     Watir::BaseElement#exists? (lib/watir-webdriver/base_element.rb:168)
     Watir::BaseElement#fire_event (lib/watir-webdriver/base_element.rb:262)
     Watir::BaseElement#flash (lib/watir-webdriver/base_element.rb:217)
     Watir::BaseElement#focus (lib/watir-webdriver/base_element.rb:257)
     Watir::BaseElement#html (lib/watir-webdriver/base_element.rb:241)
     Watir::BaseElement#initialize (lib/watir-webdriver/base_element.rb:159)
     Watir::BaseElement#inspect (lib/watir-webdriver/base_element.rb:176)
     Watir::BaseElement#parent (lib/watir-webdriver/base_element.rb:268)
     Watir::BaseElement#right_click (lib/watir-webdriver/base_element.rb:209)
     Watir::BaseElement#run_checkers (lib/watir-webdriver/base_element.rb:302)
     Watir::BaseElement#send_keys (lib/watir-webdriver/base_element.rb:246)
     Watir::BaseElement#style (lib/watir-webdriver/base_element.rb:293)
     Watir::BaseElement#tag_name (lib/watir-webdriver/base_element.rb:189)
     Watir::BaseElement#text (lib/watir-webdriver/base_element.rb:184)
     Watir::BaseElement#value (lib/watir-webdriver/base_element.rb:226)
     Watir::BaseElement#visible? (lib/watir-webdriver/base_element.rb:288)
     Watir::BaseElement#wd (lib/watir-webdriver/base_element.rb:286)
     Watir::BaseElement.attribute_list (lib/watir-webdriver/base_element.rb:18)
     Watir::BaseElement.attributes (lib/watir-webdriver/base_element.rb:27)
     Watir::BaseElement.default_selector (lib/watir-webdriver/base_element.rb:43)
     Watir::BaseElement.default_selector= (lib/watir-webdriver/base_element.rb:12)
     Watir::BaseElement.typed_attributes (lib/watir-webdriver/base_element.rb:14)
     Watir::BaseElement::IGNORED_ATTRIBUTES (lib/watir-webdriver/base_element.rb:9)
     Watir::Bdo (lib/watir-webdriver/elements/generated.rb:1047)
     Watir::ButtonsCollection (lib/watir-webdriver/collections/buttons_collection.rb:2)
     Watir::Cite (lib/watir-webdriver/elements/generated.rb:1107)
     Watir::Code (lib/watir-webdriver/elements/generated.rb:1157)
     Watir::Col (lib/watir-webdriver/elements/generated.rb:1247)
     Watir::Dd (lib/watir-webdriver/elements/generated.rb:987)
     Watir::Del (lib/watir-webdriver/elements/generated.rb:1327)
     Watir::Dfn (lib/watir-webdriver/elements/generated.rb:1097)
     Watir::Dt (lib/watir-webdriver/elements/generated.rb:1237)
     Watir::Em (lib/watir-webdriver/elements/generated.rb:1337)
     Watir::Figure (lib/watir-webdriver/elements/generated.rb:1147)
     Watir::Footer (lib/watir-webdriver/elements/generated.rb:1297)
     Watir::H2 (lib/watir-webdriver/elements/headings.rb:9)
     Watir::H3 (lib/watir-webdriver/elements/headings.rb:17)
     Watir::H4 (lib/watir-webdriver/elements/headings.rb:25)
     Watir::H5 (lib/watir-webdriver/elements/headings.rb:33)
     Watir::H6 (lib/watir-webdriver/elements/headings.rb:41)
     Watir::Header (lib/watir-webdriver/elements/generated.rb:1187)
     Watir::Hgroup (lib/watir-webdriver/elements/generated.rb:1197)
     Watir::I (lib/watir-webdriver/elements/generated.rb:1257)
     Watir::Input#to_select_list (lib/watir-webdriver/elements/input.rb:49)
     Watir::Ins (lib/watir-webdriver/elements/generated.rb:1117)
     Watir::Kbd (lib/watir-webdriver/elements/generated.rb:1087)
     Watir::Link (lib/watir-webdriver/elements/link.rb:3)
     Watir::Link#url (lib/watir-webdriver/elements/link.rb:10)
     Watir::Mark (lib/watir-webdriver/elements/generated.rb:1077)
     Watir::Nav (lib/watir-webdriver/elements/generated.rb:1007)
     Watir::Noscript (lib/watir-webdriver/elements/generated.rb:1137)
     Watir::Q (lib/watir-webdriver/elements/generated.rb:1167)
     Watir::Rp (lib/watir-webdriver/elements/generated.rb:1057)
     Watir::Rt (lib/watir-webdriver/elements/generated.rb:1067)
     Watir::Ruby (lib/watir-webdriver/elements/generated.rb:1307)
     Watir::Samp (lib/watir-webdriver/elements/generated.rb:1217)
     Watir::Section (lib/watir-webdriver/elements/generated.rb:1227)
     Watir::SelectList (lib/watir-webdriver/elements/select_list.rb:3)
     Watir::SelectList#clear (lib/watir-webdriver/elements/select_list.rb:23)
     Watir::SelectList#enabled? (lib/watir-webdriver/elements/select_list.rb:15)
     Watir::SelectList#include? (lib/watir-webdriver/elements/select_list.rb:45)
     Watir::SelectList#includes? (lib/watir-webdriver/elements/select_list.rb:50)
     Watir::SelectList#options (lib/watir-webdriver/elements/select_list.rb:33)
     Watir::SelectList#select (lib/watir-webdriver/elements/select_list.rb:61)
     Watir::SelectList#select_value (lib/watir-webdriver/elements/select_list.rb:75)
     Watir::SelectList#selected? (lib/watir-webdriver/elements/select_list.rb:87)
     Watir::SelectList#selected_options (lib/watir-webdriver/elements/select_list.rb:117)
     Watir::SelectList#value (lib/watir-webdriver/elements/select_list.rb:105)
     Watir::Small (lib/watir-webdriver/elements/generated.rb:1287)
     Watir::Strong (lib/watir-webdriver/elements/generated.rb:1177)
     Watir::Sub (lib/watir-webdriver/elements/generated.rb:1027)
     Watir::Sup (lib/watir-webdriver/elements/generated.rb:1037)
     Watir::TFoot (lib/watir-webdriver/elements/generated.rb:1017)
     Watir::TextFieldsCollection (lib/watir-webdriver/collections/text_fields_collection.rb:2)
     Watir::Thead (lib/watir-webdriver/elements/generated.rb:977)
     Watir::TrsCollection (lib/watir-webdriver/collections/table_rows_collection.rb:2)
     Watir::Var (lib/watir-webdriver/elements/generated.rb:1267)


### 0.0.6



### 0.0.5

   Modified objects:

     Watir::Frame#locate (lib/watir-webdriver/elements/frame.rb:12)


### 0.0.4

   Added objects:

     Watir::ElementLocator#should_use_label_element? (lib/watir-webdriver/locators/element_locator.rb:242)
     Watir::ElementLocator#valid_attribute? (lib/watir-webdriver/locators/element_locator.rb:238)

   Modified objects:

     Watir::BaseElement#attribute_value (lib/watir-webdriver/base_element.rb:231)
     Watir::BaseElement#style (lib/watir-webdriver/base_element.rb:289)
     Watir::BaseElement#value (lib/watir-webdriver/base_element.rb:226)
     Watir::ElementLocator#assert_valid_as_attribute (lib/watir-webdriver/locators/element_locator.rb:204)
     Watir::ElementLocator#equal_pair (lib/watir-webdriver/locators/element_locator.rb:262)
     Watir::ElementLocator#wd_find_by_regexp_selector (lib/watir-webdriver/locators/element_locator.rb:125)
     Watir::ElementLocator::WD_FINDERS (lib/watir-webdriver/locators/element_locator.rb:7)
     Watir::Input#type (lib/watir-webdriver/elements/input.rb:18)
     Watir::TextFieldLocator#lhs_for (lib/watir-webdriver/locators/text_field_locator.rb:34)


### 0.0.3

   Added objects:

     Watir::SelectList#options (lib/watir-webdriver/elements/select_list.rb:33)

   Modified objects:

     Watir::ElementLocator#fetch_value (lib/watir-webdriver/locators/element_locator.rb:134)
     Watir::ElementLocator::WD_FINDERS (lib/watir-webdriver/locators/element_locator.rb:7)
     Watir::TextFieldLocator#build_xpath (lib/watir-webdriver/locators/text_field_locator.rb:12)


### 0.0.2



### 0.0.1

   Modified objects:

     Watir::Option#select (lib/watir-webdriver/elements/option.rb:14)


### 0.0.1.dev7

   Added objects:

     Watir::BaseElement#send_keys (lib/watir-webdriver/base_element.rb:242)
     Watir::Frame#assert_exists (lib/watir-webdriver/elements/frame.rb:25)
     Watir::Frame#element_by_xpath (lib/watir-webdriver/elements/frame.rb:35)
     Watir::Frame#elements_by_xpath (lib/watir-webdriver/elements/frame.rb:40)
     Watir::Frame#execute_script (lib/watir-webdriver/elements/frame.rb:31)
     Watir::Frame#initialize (lib/watir-webdriver/elements/frame.rb:7)
     Watir::Frame#locate (lib/watir-webdriver/elements/frame.rb:12)
     Watir::Frame::VALID_LOCATORS (lib/watir-webdriver/elements/frame.rb:5)

   Modified objects:

     Watir::BaseElement#exist? (lib/watir-webdriver/base_element.rb:172)
     Watir::BaseElement#exists? (lib/watir-webdriver/base_element.rb:166)
     Watir::BaseElement#fire_event (lib/watir-webdriver/base_element.rb:251)
     Watir::Browser#initialize (lib/watir-webdriver/browser.rb:25)
     Watir::Option#select (lib/watir-webdriver/elements/option.rb:14)
     Watir::XpathSupport#elements_by_xpath (lib/watir-webdriver/xpath_support.rb:21)

   Removed objects:

     Watir::Container#frame (lib/watir-webdriver.rb:59)
     Watir::Container#frames (lib/watir-webdriver.rb:60)


### 0.0.1.dev6

   Added objects:

     Watir::Applet (lib/watir-webdriver/elements/generated.rb:613)
     Watir::Audio (lib/watir-webdriver/elements/generated.rb:305)
     Watir::BaseElement::IGNORED_ATTRIBUTES (lib/watir-webdriver/base_element.rb:9)
     Watir::BaseFont (lib/watir-webdriver/elements/generated.rb:673)
     Watir::Command (lib/watir-webdriver/elements/generated.rb:593)
     Watir::Directory (lib/watir-webdriver/elements/generated.rb:723)
     Watir::Font (lib/watir-webdriver/elements/font.rb:4)
     Watir::Frame (lib/watir-webdriver/elements/generated.rb:643)
     Watir::FrameSet (lib/watir-webdriver/elements/generated.rb:633)
     Watir::Marquee (lib/watir-webdriver/elements/generated.rb:623)
     Watir::Media (lib/watir-webdriver/elements/generated.rb:291)
     Watir::Menu (lib/watir-webdriver/elements/generated.rb:857)
     Watir::Object (lib/watir-webdriver/elements/generated.rb:271)
     Watir::Script (lib/watir-webdriver/elements/generated.rb:77)
     Watir::Video (lib/watir-webdriver/elements/generated.rb:295)

   Modified objects:

     Watir.element_class_for (lib/watir-webdriver.rb:23)
     Watir::BaseElement.attribute_list (lib/watir-webdriver/base_element.rb:105)
     Watir::BaseElement.attributes (lib/watir-webdriver/base_element.rb:16)
     Watir::Browser#initialize (lib/watir-webdriver/browser.rb:25)
     Watir::ElementLocator#by_id (lib/watir-webdriver/locators/element_locator.rb:200)
     Watir::ElementLocator#locate (lib/watir-webdriver/locators/element_locator.rb:16)
     Watir::XpathSupport#element_by_xpath (lib/watir-webdriver/xpath_support.rb:10)
     Watir::XpathSupport#elements_by_xpath (lib/watir-webdriver/xpath_support.rb:21)

   Removed objects:

     Watir::BaseElement.add_attributes (lib/watir-webdriver/base_element.rb:86)
     Watir::BaseElement.attribute_for_method (lib/watir-webdriver/base_element.rb:134)
     Watir::BaseElement.collection_method (lib/watir-webdriver/base_element.rb:74)
     Watir::BaseElement.container_method (lib/watir-webdriver/base_element.rb:67)
     Watir::BaseElement.define_attribute (lib/watir-webdriver/base_element.rb:28)
     Watir::BaseElement.define_boolean_attribute (lib/watir-webdriver/base_element.rb:53)
     Watir::BaseElement.define_int_attribute (lib/watir-webdriver/base_element.rb:60)
     Watir::BaseElement.define_string_attribute (lib/watir-webdriver/base_element.rb:46)
     Watir::BaseElement.identifier (lib/watir-webdriver/base_element.rb:96)
     Watir::BaseElement.method_name_for (lib/watir-webdriver/base_element.rb:114)
     Watir::Unknown (lib/watir-webdriver/elements/generated.rb:489)


### 0.0.1.dev5

   Added objects:

     Watir::SelectList#include? (lib/watir-webdriver/elements/select_list.rb:40)

   Modified objects:

     Watir::Browser#refresh (lib/watir-webdriver/browser.rb:95)
     Watir::SelectList#includes? (lib/watir-webdriver/elements/select_list.rb:23)
     Watir::Table#to_a (lib/watir-webdriver/elements/table.rb:5)
     Watir::TextField#inspect (lib/watir-webdriver/elements/text_field.rb:15)
     Watir::TextField#set (lib/watir-webdriver/elements/text_field.rb:23)
     Watir::TextField#value= (lib/watir-webdriver/elements/text_field.rb:31)

   Removed objects:

     Watir::Button#locate (lib/watir-webdriver/elements/button.rb:8)
     Watir::Hidden#value= (lib/watir-webdriver/elements/hidden.rb:10)
     Watir::TableRow#locate (lib/watir-webdriver/elements/table_row.rb:8)
     Watir::TextField#locate (lib/watir-webdriver/elements/text_field.rb:11)
     Watir::TextField#selector_string (lib/watir-webdriver/elements/text_field.rb:19)


### 0.0.1.dev4

   Added objects:

     Watir::Browser#browser (lib/watir-webdriver/browser.rb:146)

   Modified objects:

     Watir::Browser#goto (lib/watir-webdriver/browser.rb:35)
     Watir::ElementCollection#length (lib/watir-webdriver/collections/element_collection.rb:14)
     Watir::ElementCollection#size (lib/watir-webdriver/collections/element_collection.rb:17)
     Watir::SelectList#clear (lib/watir-webdriver/elements/select_list.rb:13)
     Watir::SelectList#select (lib/watir-webdriver/elements/select_list.rb:26)
     Watir::SelectList#select_value (lib/watir-webdriver/elements/select_list.rb:31)
     Watir::SelectList#selected? (lib/watir-webdriver/elements/select_list.rb:35)

   Removed objects:

     Watir::ButtonsCollection#elements (lib/watir-webdriver/collections/buttons_collection.rb:4)
     Watir::Container.add (lib/watir-webdriver/container.rb:5)
     Watir::ElementCollection#elements (lib/watir-webdriver/collections/element_collection.rb:36)
     Watir::Object (lib/watir-webdriver/elements/generated.rb:55)
     Watir::TextFieldsCollection#elements (lib/watir-webdriver/collections/text_fields_collection.rb:4)
     Watir::TrsCollection#elements (lib/watir-webdriver/collections/table_rows_collection.rb:4)


### 0.0.1.dev3

   Modified objects:

     Watir::Browser#refresh (lib/watir-webdriver/browser.rb:86)
     Watir::Browser#text (lib/watir-webdriver/browser.rb:73)


### 0.0.1.dev2

   Added objects:

     Watir::CheckBox#clear (lib/watir-webdriver/elements/checkbox.rb:25)
     Watir::CheckBox#set? (lib/watir-webdriver/elements/checkbox.rb:20)
     Watir::Exception::UnknownRowException (lib/watir-webdriver/exception.rb:18)
     Watir::Input#type (lib/watir-webdriver/elements/input.rb:11)
     Watir::Radio#set? (lib/watir-webdriver/elements/radio.rb:16)
     Watir::TextField#type (lib/watir-webdriver/elements/text_field.rb:7)

   Modified objects:

     Watir::BaseElement#fire_event (lib/watir-webdriver/base_element.rb:245)
     Watir::BaseElement#focus (lib/watir-webdriver/base_element.rb:241)
     Watir::BaseElement#html (lib/watir-webdriver/base_element.rb:228)
     Watir::BaseElement#value (lib/watir-webdriver/base_element.rb:217)
     Watir::Browser#execute_script (lib/watir-webdriver/browser.rb:98)
     Watir::Button#text (lib/watir-webdriver/elements/button.rb:12)
     Watir::Radio#set (lib/watir-webdriver/elements/radio.rb:11)

   Removed objects:

     Watir::SharedRadioCheckbox (lib/watir-webdriver/elements/shared_radio_checkbox.rb:3)
     Watir::SharedRadioCheckbox#clear (lib/watir-webdriver/elements/shared_radio_checkbox.rb:9)
     Watir::SharedRadioCheckbox#set? (lib/watir-webdriver/elements/shared_radio_checkbox.rb:4)


