module Watir
  class HttpClient < Selenium::WebDriver::Remote::Http::Default
    # TODO: Remove for Watir 7; :client_timeout will be marked deprecated in 6.19
    # :open_timeout should have been changed in Selenium a while back, is in 4.beta2
    def initialize(open_timeout: nil, read_timeout: nil, client_timeout: nil)
      read_timeout ||= client_timeout
      open_timeout ||= client_timeout || 60
      super(open_timeout: open_timeout, read_timeout: read_timeout)
    end

    def request(verb, url, headers, payload, redirects = 0)
      headers['User-Agent'] = "#{headers['User-Agent']} watir/#{Watir::VERSION}"

      super(verb, url, headers, payload, redirects)
    end
  end
end
