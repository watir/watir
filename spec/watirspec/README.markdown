What
====

This repository is intended to be used as a git submodule for projects that want to implement [Watir](http://watir.com)'s API.

The specs run a small Sinatra webapp (_WatirSpec::Server_) to simulate interacting with a web server. However, most specs use the _file://_ scheme to avoid hitting the server.

How to use
==========

First add the submodule to _spec/watirspec_:

    $ git submodule add git://github.com/watir/watirspec.git spec/watirspec

The specs will look for *implementation.rb* in its parent directory (i.e. _spec/_). In this file you need to define some details about your implementation that WatirSpec needs to know

Here's an example of what _spec/implementation.rb_ would look like for the imaginary implementation AwesomeWatir:

```ruby
$LOAD_PATH.unshift(«lib folder»)
require "awesomewatir"

include AwesomeWatir::Exception # needed for now..

WatirSpec::Implementation do |imp|
  imp.name = :awesome

  imp.browser_class = AwesomeWatir::Browser
  imp.browser_args  = [:some => 'option']
end

WatirSpec.persistent_browser = false               # defaults to true, but can be disabled if needed
WatirSpec::Server.autorun    = false               # defaults to true, but can be disabled if needed

WatirSpec::Server.get("/my_route") { "content" }   # add routes to the server for implementation-specific specs
```

Implementation-specific specs should be placed at the root of the _spec/_ folder.
To use the setup code from watirspec, simply require `"watirspec/spec_helper"` (which in turn will load your `spec/spec_helper.rb`).

Guards
------

WatirSpec includes a system to guard specs that are failing.

WRITE ME

- what guards are available (bug, not\_compliant, deviates\_on, ...)
- setting a custom guard proc
    (example in http://github.com/watir/watir-webdriver/blob/master/spec/implementation.rb)

Where
=====

* Source : [GitHub](http://github.com/watir/watirspec/tree/master)
* Issues : [GitHub](http://github.com/watir/watirspec/issues)
