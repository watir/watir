module Watir
  class HttpClient < Selenium::WebDriver::Remote::Http::Default
    def request(verb, url, headers, payload, redirects = 0)
      headers['User-Agent'] = "#{headers['User-Agent']} watir/#{Watir::VERSION}"

      super(verb, url, headers, payload, redirects)
    end
  end
end
