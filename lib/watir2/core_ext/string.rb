# encoding: utf-8
class String
  #
  # Convert from camel case to snake case
  #
  #     'FooBar'.snake_case # => "foo_bar"
  #

  def snake_case
    gsub(/\B[A-Z][^A-Z]/, '_\&').downcase.gsub(' ', '_')
  end

  #
  # Convert from snake case to camel case
  #
  #     'foo_bar'.camel_case # => "FooBar"
  #

  def camel_case
   split('_').map { |e| e.capitalize }.join
  end
end
