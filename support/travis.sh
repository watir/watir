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
  PHANTOMJS_NAME=phantomjs-1.9.0-linux-x86_64
  curl -L -O "https://phantomjs.googlecode.com/files/$PHANTOMJS_NAME.tar.bz2"
  tar -xvjf $PHANTOMJS_NAME.tar.bz2
  chmod +x $PHANTOMJS_NAME/bin/phantomjs
  sudo cp $PHANTOMJS_NAME/bin/phantomjs /usr/local/phantomjs/bin/phantomjs
  phantomjs --version
fi
