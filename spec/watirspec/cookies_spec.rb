require File.expand_path("../spec_helper", __FILE__)

describe "Browser#cookies" do
  after { browser.cookies.clear }

  it 'gets an empty list of cookies' do
    browser.goto WatirSpec.url_for 'collections.html' # no cookie set.
    browser.cookies.to_a.should == []
  end

  it "gets any cookies set" do
    browser.goto set_cookie_url

    verify_cookies_count 1

    cookie = browser.cookies.to_a.first
    cookie[:name].should == 'monster'
    cookie[:value].should == '1'
  end

  not_compliant_on [:webdriver, :internet_explorer] do
    it 'adds a cookie' do
      browser.goto set_cookie_url
      verify_cookies_count 1

      browser.cookies.add 'foo', 'bar'
      verify_cookies_count 2
    end
  end

  not_compliant_on [:webdriver, :chrome], [:webdriver, :internet_explorer], :phantomjs do
    it 'adds a cookie with options' do
      browser.goto set_cookie_url

      expires = Time.now + 10000
      options = {:path    => "/set_cookie",
                 :secure  => true,
                 :expires => expires}

      deviates_on :watir_classic do
        # secure cookie can't be accessed running on WatirSpec test server
        options.delete(:secure)
      end

      browser.cookies.add 'a', 'b', options
      cookie = browser.cookies.to_a.find { |e| e[:name] == 'a' }
      cookie.should_not be_nil

      cookie[:name].should == 'a'
      cookie[:value].should == 'b'

      not_compliant_on :watir_classic do
        cookie[:path].should == "/set_cookie"
        cookie[:secure].should be_true

        cookie[:expires].should be_kind_of(Time)

        # a few ms slack
        cookie[:expires].to_i.should be_within(2).of(expires.to_i)
      end
    end
  end

  not_compliant_on [:webdriver, :internet_explorer] do
    it 'removes a cookie' do
      browser.goto set_cookie_url
      verify_cookies_count 1

      browser.cookies.delete 'monster'
      verify_cookies_count 0
    end

    it 'clears all cookies' do
      browser.goto set_cookie_url
      browser.cookies.add 'foo', 'bar'
      verify_cookies_count 2

      browser.cookies.clear
      verify_cookies_count 0
    end
  end

  def set_cookie_url
    # add timestamp to url to avoid caching in IE8
    WatirSpec.url_for('set_cookie/index.html', :needs_server => true) + "?t=#{Time.now.to_i + Time.now.usec}"
  end

  def verify_cookies_count expected_size
    cookies = browser.cookies.to_a
    cookies.size.should eq(expected_size), "expected #{expected_size} cookies, got #{cookies.size}: #{cookies.inspect}"
  end
end
