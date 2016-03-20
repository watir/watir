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
  PHANTOMJS_NAME=phantomjs-2.1.1-linux-x86_64
  curl -L -O "https://bitbucket.org/ariya/phantomjs/downloads/${PHANTOMJS_NAME}.tar.bz2"
  tar -xvjf $PHANTOMJS_NAME.tar.bz2
  chmod +x $PHANTOMJS_NAME/bin/phantomjs
  cp $PHANTOMJS_NAME/bin/phantomjs travis-phantomjs/phantomjs
  phantomjs --version
fi
