module WatirSpec
  class Implementation

    attr_writer :name, :guard_proc, :browser_class
    attr_accessor :browser_args

    def initialize
      @guard_proc = nil
    end

    def browser_class
      @browser_class || raise("browser_class not set")
    end

    def name
      @name || raise("implementation name not set")
    end

    def matches_guard?(args)
      return @guard_proc.call(args) if @guard_proc

      args.include? name
    end

    def matching_guards_in(guards)
      result = []
      guards.each { |args, data| data.each {|d| result << d } if matches_guard?(args) }

      result
    end

  end # Implementation
end # WatirSpec

if __FILE__ == $0
  require "rubygems"
  require 'rspec/autorun'

  describe WatirSpec::Implementation do
    before { @impl = WatirSpec::Implementation.new }

    it "finds matching guards" do
      guards = {
        [:watir_classic] => [
          {:name => :not_compliant, :data => {:file => "./spec/watirspec/div_spec.rb:108"}},
          {:name => :deviates,      :data => {:file=>"./spec/watirspec/div_spec.rb:114"}},
          {:name => :not_compliant, :data => {:file=>"./spec/watirspec/div_spec.rb:200"}},
          {:name => :bug,           :data => {:file=>"./spec/watirspec/div_spec.rb:228", :key=>"WTR-350"}}
        ],
        [:celerity] => [
          {:name => :deviates,      :data => {:file=>"./spec/watirspec/div_spec.rb:143"}}
        ]
      }
      @impl.name = :celerity
      @impl.matching_guards_in(guards).should == [{:name => :deviates, :data => {:file=>"./spec/watirspec/div_spec.rb:143"}}]
    end
  end
end
