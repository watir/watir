#/bin/sh

set -e
set -x

export CHROME_REVISION=228611
export CHROMEDRIVER_VERSION=2.9

sh -e /etc/init.d/xvfb start
git submodule update --init

mkdir ~/.yard
bundle exec yard config -a autoload_plugins yard-doctest

if [[ "$WATIR_WEBDRIVER_BROWSER" = "chrome" ]]; then
  sudo chmod 1777 /dev/shm

  sudo apt-get update
  sudo apt-get install -y unzip libxss1

  curl -L -O "http://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/${CHROME_REVISION}/chrome-linux.zip"
  unzip chrome-linux.zip

  # chrome sandbox doesn't currently work on travis: https://github.com/travis-ci/travis-ci/issues/938
  sudo chown root:root chrome-linux/chrome_sandbox
  sudo chmod 4755 chrome-linux/chrome_sandbox
  export CHROME_DEVEL_SANDBOX="$PWD/chrome-linux/chrome_sandbox"

  curl -L -O "http://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip"
  unzip chromedriver_linux64.zip

  mv chromedriver chrome-linux/chromedriver
  chmod +x chrome-linux/chromedriver
fi

if [[ "$WATIR_WEBDRIVER_BROWSER" = "phantomjs" ]]; then
  PHANTOMJS_NAME=phantomjs-1.9.0-linux-x86_64
  curl -L -O "https://phantomjs.googlecode.com/files/$PHANTOMJS_NAME.tar.bz2"
  tar -xvjf $PHANTOMJS_NAME.tar.bz2
  chmod +x $PHANTOMJS_NAME/bin/phantomjs
  sudo cp $PHANTOMJS_NAME/bin/phantomjs /usr/local/phantomjs/bin/phantomjs
  phantomjs --version
fi
