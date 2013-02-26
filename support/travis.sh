#/bin/sh

set -e
set -x

CHROME_REVISION=142910
sh -e /etc/init.d/xvfb start && git submodule update --init

if [[ "$WATIR_WEBDRIVER_BROWSER" = "chrome" ]]; then
  sudo apt-get install -y unzip libxss1
  curl -L -O "http://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux/$CHROME_REVISION/chrome-linux.zip"
  unzip chrome-linux.zip
  curl -L "http://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux/$CHROME_REVISION/chrome-linux.test/chromedriver" > chrome-linux/chromedriver
  chmod +x chrome-linux/chromedriver
fi

if [[ "$WATIR_WEBDRIVER_BROWSER" = "phantomjs" ]]; then
  curl -L -O "http://phantomjs.googlecode.com/files/phantomjs-1.8.1-linux-i686.tar.bz2"
  bzip2 -cd phantomjs-1.8.1-linux-i686.tar.bz2 | tar xvf -
  chmod +x phantomjs-1.8.1-linux-i686/bin/phantomjs
  sudo cp phantomjs-1.8.1-linux-i686/bin/phantomjs /usr/local/phantomjs/bin/phantomjs
  phantomjs --version
fi
