#/bin/sh

CHROME_REVISION=117966
sh -e /etc/init.d/xvfb start && git submodule update --init || exit 1

if [[ "$WATIR_WEBDRIVER_BROWSER" = "chrome" ]]; then
  # deps
  sudo apt-get install -y unzip libxss1

  # download and unpack chrome
  curl -L -O "http://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux/$CHROME_REVISION/chrome-linux.zip"
  unzip chrome-linux.zip
  ln -s chrome-linux/chrome chrome-linux/google-chrome

  # download chromedriver
  curl -L "http://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux/$CHROME_REVISION/chrome-linux.test/chromedriver" > chromedriver
  chmod +x chromedriver

  # start the server
  ./chromedriver &
fi

