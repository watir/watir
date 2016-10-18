if "%RAKE_TASK%"=="spec:firefox" (
  choco install -y curl
  choco install -y 7zip.commandline
  curl -L -O --insecure https://github.com/mozilla/geckodriver/releases/download/v0.11.1/geckodriver-v0.11.1-win32.zip
  7za e geckodriver-v0.11.1-win32.zip
  move geckodriver.exe C:\Tools\WebDriver

  geckodriver.exe --version
)
