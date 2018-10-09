require 'yaml'

module Watir
  class Cookies
    def initialize(control)
      @control = control
    end

    #
    # Returns array of cookies.
    #
    # @example
    #   browser.cookies.to_a
    #   #=> {:name=>"my_session", :value=>"BAh7B0kiD3Nlc3Npb25faWQGOgZFRkk", :domain=>"mysite.com"}
    #
    # @return [Array<Hash>]
    #

    def to_a
      @control.all_cookies.map do |e|
        e.merge(expires: e[:expires] ? e[:expires].to_time : nil)
      end
    end

    #
    # Returns a cookie by name.
    #
    # @example
    #   browser.cookies[:my_session]
    #   #=> {:name=>"my_session", :value=>"BAh7B0kiD3Nlc3Npb25faWQGOgZFRkk", :domain=>"mysite.com"}
    #
    # @param [Symbol] name
    # @return <Hash> or nil if not found
    #

    def [](name)
      to_a.find { |c| c[:name] == name.to_s }
    end

    #
    # Adds new cookie.
    #
    # @example
    #   browser.cookies.add 'my_session', 'BAh7B0kiD3Nlc3Npb25faWQGOgZFRkk', secure: true
    #
    # @param [String] name
    # @param [String] value
    # @param [Hash] opts
    # @option opts [Boolean] :secure
    # @option opts [String] :path
    # @option opts [Time, DateTime, NilClass] :expires
    # @option opts [String] :domain
    #

    def add(name, value, opts = {})
      cookie = {
        name: name,
        value: value
      }
      cookie[:secure] = opts[:secure] if opts.key?(:secure)
      cookie[:path] = opts[:path] if opts.key?(:path)
      expires = opts[:expires]
      if expires
        cookie[:expires] = ::Time.parse(expires) if expires.is_a?(String) else expires
      end
      cookie[:domain] = opts[:domain] if opts.key?(:domain)

      @control.add_cookie cookie
    end

    #
    # Deletes cookie by given name.
    #
    # @example
    #   browser.cookies.delete 'my_session'
    #
    # @param [String] name
    #

    def delete(name)
      @control.delete_cookie(name)
    end

    #
    # Deletes all cookies.
    #
    # @example
    #   browser.cookies.clear
    #

    def clear
      @control.delete_all_cookies
    end

    #
    # Save cookies to file
    #
    # @example
    #   browser.cookies.save '.cookies'
    #
    # @param [String] file
    #

    def save(file = '.cookies')
      IO.write(file, to_a.to_yaml)
    end

    #
    # Load cookies from file
    #
    # @example
    #   browser.cookies.load '.cookies'
    #
    # @param [String] file
    #

    def load(file = '.cookies')
      YAML.safe_load(IO.read(file), [::Symbol, ::Time]).each do |c|
        add(c.delete(:name), c.delete(:value), c)
      end
    end
  end # Cookies
end # Watir
