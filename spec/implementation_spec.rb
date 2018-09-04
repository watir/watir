require 'watirspec_helper'

describe WatirSpec::Implementation do
  before { @impl = WatirSpec::Implementation.new }

  it 'finds matching guards' do
    guards = {
      [:firefox] => [
        {name: :not_compliant, data: {file: './spec/watirspec/div_spec.rb:108'}},
        {name: :deviates,      data: {file: './spec/watirspec/div_spec.rb:114'}},
        {name: :not_compliant, data: {file: './spec/watirspec/div_spec.rb:200'}},
        {name: :bug,           data: {file: './spec/watirspec/div_spec.rb:228', key: 'WTR-350'}}
      ],
      [:chrome] => [
        {name: :not_compliant, data: {file: './spec/watirspec/div_spec.rb:109'}},
        {name: :deviates,      data: {file: './spec/watirspec/div_spec.rb:115'}},
        {name: :not_compliant, data: {file: './spec/watirspec/div_spec.rb:201'}},
        {name: :bug,           data: {file: './spec/watirspec/div_spec.rb:229', key: 'WTR-349'}}
      ]
    }
    @impl.name = :firefox
    expect(@impl.matching_guards_in(guards)).to eq(guards.first[1])
  end
end
