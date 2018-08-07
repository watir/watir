#!/bin/bash

set -e
set -x

sh -e /etc/init.d/xvfb start

if [[ "$RAKE_TASK" = "yard:doctest" ]]; then
  mkdir ~/.yard
  bundle exec yard config -a autoload_plugins yard-doctest
fi

pwd
echo "$RUBY_VERSION" >> .ruby-version
cat .ruby-version
