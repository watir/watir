#/bin/sh

set -e
set -x

CHROME_REVISION=191150
sh -e /etc/init.d/xvfb start && git submodule update --init

if [[ "$WATIR_WEBDRIVER_BROWSER" = "chrome" ]]; then
  sudo apt-get install -y unzip libxss1
  curl -L -O "http://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/$CHROME_REVISION/chrome-linux.zip"
  unzip chrome-linux.zip
  curl -L "http://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/$CHROME_REVISION/chrome-linux.test/chromedriver" > chrome-linux/chromedriver
  chmod +x chrome-linux/chromedriver
  sudo chmod 1777 /dev/shm
fi

if [[ "$WATIR_WEBDRIVER_BROWSER" = "phantomjs" ]]; then
  curl -L -O "https://dl.dropbox.com/u/2731643/phantomjs/phantomjs-latest.tar.bz2"
  mkdir phantomjs
  tar -xvjf phantomjs-latest.tar.bz2 -C phantomjs
  cat phantomjs/phantomjs.version
  chmod +x phantomjs/phantomjs
  sudo cp phantomjs/phantomjs /usr/local/phantomjs/bin/phantomjs
  phantomjs --version
fi
