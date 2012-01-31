require File.expand_path("../spec_helper", __FILE__)

describe "Browser#cookies" do
  after { browser.cookies.clear }

  it 'gets an empty list of cookies' do
    browser.goto WatirSpec.url_for 'collections.html' # no cookie set.
    browser.cookies.to_a.should == []
  end

  it "gets any cookies set" do
    browser.goto WatirSpec.url_for('set_cookie', :needs_server => true)

    all = browser.cookies.to_a
    all.size.should == 1

    cookie = browser.cookies.to_a.first

    cookie[:name].should == 'monster'
    cookie[:value].should == '1'
  end

  it 'adds a cookie' do
    browser.goto WatirSpec.url_for('set_cookie', :needs_server => true)
    browser.cookies.to_a.size.should == 1

    browser.cookies.add 'foo', 'bar'
    browser.cookies.to_a.size.should == 2
  end

  it 'adds a cookie with options' do
    browser.goto WatirSpec.url_for('set_cookie', :needs_server => true)

    expires = Time.now + 10000
    browser.cookies.add 'a', 'b', :path => "/set_cookie",
                                  :secure => true,
                                  :expires => expires

    cookie = browser.cookies.to_a.find { |e| e[:name] == 'a' }
    cookie.should_not be_nil

    cookie[:name].should == 'a'
    cookie[:value].should == 'b'
    cookie[:path].should == "/set_cookie"
    cookie[:secure].should be_true

    cookie[:expires].should be_kind_of(Time)

    # a few ms slack
    cookie[:expires].to_i.should be_within(2).of(expires.to_i)
  end

  it 'removes a cookie' do
    browser.goto WatirSpec.url_for('set_cookie', :needs_server => true)

    browser.cookies.to_a.size.should == 1
    browser.cookies.delete 'monster'
    browser.cookies.to_a.size.should == 0
  end

  it 'clears all cookies' do
    browser.goto WatirSpec.url_for('set_cookie', :needs_server => true)
    browser.cookies.add 'foo', 'bar'
    browser.cookies.to_a.size.should == 2

    browser.cookies.clear
    browser.cookies.to_a.size.should == 0
  end
end
