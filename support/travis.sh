#/bin/sh

set -e
set -x

sh -e /etc/init.d/xvfb start
git submodule update --init

mkdir ~/.yard
bundle exec yard config -a autoload_plugins yard-doctest

if [[ "$RAKE_TASK" = "spec:chrome" ]]; then
  export CHROME_REVISION=354250
  export CHROMEDRIVER_VERSION=`curl -s http://chromedriver.storage.googleapis.com/LATEST_RELEASE`

  curl -L -O "http://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/${CHROME_REVISION}/chrome-linux.zip"
  unzip chrome-linux.zip

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
