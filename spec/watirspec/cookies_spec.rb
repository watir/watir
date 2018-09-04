require 'watirspec_helper'

describe 'Browser#cookies' do
  after { browser.cookies.clear }

  it 'gets an empty list of cookies' do
    browser.goto WatirSpec.url_for 'collections.html' # no cookie set.
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

  not_compliant_on :internet_explorer do
    it 'adds a cookie' do
      browser.goto set_cookie_url
      verify_cookies_count 1

      browser.cookies.add 'foo', 'bar'
      verify_cookies_count 2
    end

    it 'adds a cookie with a string expires value' do
      browser.goto set_cookie_url
      verify_cookies_count 1

      expire_time = Time.now + 10_000

      browser.cookies.add 'foo', 'bar', expires: expire_time.to_s

      cookie = browser.cookies[:foo]
      expect(cookie[:expires]).to be_kind_of(Time)
    end
  end

  # TODO: - Split this up into multiple tests or figure out which parts are not compliant
  not_compliant_on :chrome, :internet_explorer, :safari, :firefox do
    it 'adds a cookie with options' do
      browser.goto set_cookie_url

      expires = Time.now + 10_000
      options = {path: '/set_cookie',
                 secure: true,
                 expires: expires}

      browser.cookies.add 'a', 'b', options
      cookie = browser.cookies.to_a.find { |e| e[:name] == 'a' }
      expect(cookie).to_not be_nil

      expect(cookie[:name]).to eq 'a'
      expect(cookie[:value]).to eq 'b'

      expect(cookie[:path]).to eq '/set_cookie'
      expect(cookie[:secure]).to be true

      expect(cookie[:expires]).to be_kind_of(Time)
      # a few ms slack
      expect((cookie[:expires]).to_i).to be_within(2).of(expires.to_i)
    end
  end

  not_compliant_on :internet_explorer do
    it 'removes a cookie' do
      browser.goto set_cookie_url
      verify_cookies_count 1

      browser.cookies.delete 'monster'
      verify_cookies_count 0
    end

    bug 'https://code.google.com/p/selenium/issues/detail?id=5487', :safari do
      it 'clears all cookies' do
        browser.goto set_cookie_url
        browser.cookies.add 'foo', 'bar'
        verify_cookies_count 2

        browser.cookies.clear
        verify_cookies_count 0
      end
    end
  end

  not_compliant_on :internet_explorer do
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

    bug 'https://github.com/mozilla/geckodriver/issues/1000', :firefox do
      describe '#load' do
        it 'loads cookies from file' do
          browser.cookies.clear
          browser.cookies.load file
          expected = browser.cookies.to_a
          actual = YAML.safe_load(IO.read(file), [::Symbol])

          # https://code.google.com/p/selenium/issues/detail?id=6834
          expected.each { |cookie| cookie.delete(:expires) }
          actual.each { |cookie| cookie.delete(:expires) }

          expect(actual).to eq(expected)
        end
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
