require 'watirspec_helper'

describe 'Browser#cookies' do
  after { browser.cookies.clear }

  it 'gets an empty list of cookies' do
    browser.goto WatirSpec.url_for 'index.html'
    expect(browser.cookies.to_a).to eq []
  end

  it 'gets any cookies set' do
    browser.goto set_cookie_url

    verify_cookies_count 1

    cookie = browser.cookies.to_a.first
    expect(cookie[:name]).to eq 'monster'
    expect(cookie[:value]).to eq '1'
  end

  describe '#[]' do
    before do
      browser.goto set_cookie_url
      verify_cookies_count 1
    end

    it 'returns cookie by symbol name' do
      cookie = browser.cookies[:monster]
      expect(cookie[:name]).to eq('monster')
      expect(cookie[:value]).to eq('1')
    end

    it 'returns cookie by string name' do
      cookie = browser.cookies['monster']
      expect(cookie[:name]).to eq('monster')
      expect(cookie[:value]).to eq('1')
    end

    it 'returns nil if there is no cookie with such name' do
      expect(browser.cookies[:non_monster]).to eq(nil)
    end
  end

  it 'adds a cookie without options' do
    browser.goto WatirSpec.url_for 'index.html'
    verify_cookies_count 0

    browser.cookies.add 'foo', 'bar'
    verify_cookies_count 1
  end

  it 'adds a cookie with a string expires value' do
    browser.goto WatirSpec.url_for 'index.html'

    expire_time = Time.now + 10_000

    browser.cookies.add 'foo', 'bar', expires: expire_time.to_s

    cookie = browser.cookies[:foo]
    expect(cookie[:expires]).to be_kind_of(Time)
  end

  it 'adds a cookie with path',
     except: {browser: :ie, reason: 'path contains two slashes'} do
    browser.goto WatirSpec.url_for 'index.html'

    options = {path: '/set_cookie'}
    browser.cookies.add 'path', 'b', options

    expect(browser.cookies.to_a).to be_empty

    browser.goto set_cookie_url
    cookie = browser.cookies.to_a.find { |e| e[:name] == 'path' }

    expect(cookie[:name]).to eq 'path'
    expect(cookie[:value]).to eq 'b'
    expect(cookie[:path]).to eq '/set_cookie'
  end

  it 'adds a cookie with expiration' do
    browser.goto WatirSpec.url_for 'index.html'

    expires = Time.now + 10_000
    options = {expires: expires}

    browser.cookies.add 'expiration', 'b', options
    cookie = browser.cookies.to_a.first

    expect(cookie[:name]).to eq 'expiration'
    expect(cookie[:value]).to eq 'b'

    expect((cookie[:expires]).to_i).to be_within(2).of(expires.to_i)
  end

  # Pending resolution of https://github.com/w3c/webdriver/issues/1571
  it 'adding cookie with security does not raise exception but can not be retrieved',
     except: [{browser: :firefox,
               reason: 'https://github.com/mozilla/geckodriver/issues/1840'},
              {browser: %i[chrome edge], platform: :windows}] do
    browser.goto WatirSpec.url_for 'index.html'

    options = {secure: true}

    browser.cookies.add 'secure', 'b', options
    cookie = browser.cookies.to_a.find { |e| e[:name] == 'secure' }
    expect(cookie).to be_nil
  end

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

  context 'cookie file' do
    let(:file) { "#{Dir.tmpdir}/cookies" }

    before do
      browser.goto set_cookie_url
      browser.cookies.save file
    end

    describe '#save' do
      it 'saves cookies to file' do
        expect(IO.read(file)).to eq(browser.cookies.to_a.to_yaml)
      end
    end

    describe '#load', except: {browser: :ie} do
      it 'loads cookies from file' do
        browser.cookies.clear
        browser.cookies.load file
        expected = browser.cookies.to_a
        actual = YAML.safe_load(IO.read(file), [::Symbol])

        expected.each { |cookie| cookie.delete(:expires) }
        actual.each { |cookie| cookie.delete(:expires) }

        expect(actual).to eq(expected)
      end
    end
  end

  def set_cookie_url
    # add timestamp to url to avoid caching in IE8
    WatirSpec.url_for('set_cookie/index.html') + "?t=#{Time.now.to_i + Time.now.usec}"
  end

  def verify_cookies_count(expected_size)
    cookies = browser.cookies.to_a
    msg = "expected #{expected_size} cookies, got #{cookies.size}: #{cookies.inspect}"
    expect(cookies.size).to eq(expected_size), msg
  end
end
