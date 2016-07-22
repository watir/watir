#!/bin/bash

set -e
set -x

sh -e /etc/init.d/xvfb start
git submodule update --init

if [[ "$RAKE_TASK" = "yard:doctest" ]]; then
  mkdir ~/.yard
  bundle exec yard config -a autoload_plugins yard-doctest
fi

if [[ "$RAKE_TASK" = "spec:chrome" ]]; then
  # https://omahaproxy.appspot.com
  # https://commondatastorage.googleapis.com/chromium-browser-snapshots/index.html?prefix=Linux_x64/
  CHROME_REVISION=386257
  curl -L -O "http://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/${CHROME_REVISION}/chrome-linux.zip"
  unzip chrome-linux.zip

  CHROMEDRIVER_VERSION=$(curl -s http://chromedriver.storage.googleapis.com/LATEST_RELEASE)
  curl -L -O "http://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip"
  unzip chromedriver_linux64.zip

  mv chromedriver chrome-linux/chromedriver
  chmod +x chrome-linux/chromedriver
fi

if [[ "$RAKE_TASK" = "spec:phantomjs" ]]; then
  curl -L -O "https://bintray.com/artifact/download/tfortner/phantomjs-clone/p/phantomjs"
  chmod +x phantomjs

  mv phantomjs travis-phantomjs/phantomjs
  phantomjs --version
fi
