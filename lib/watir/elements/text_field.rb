module Watir
  class TextField < Input
    include UserEditable

    NON_TEXT_TYPES = %w[file radio checkbox submit reset image button hidden range color date datetime-local].freeze

    def selector_string
      selector = @selector.dup
      selector[:type] = '(any text type)'
      selector[:tag_name] = 'input'

      if @query_scope.is_a?(Browser) || @query_scope.is_a?(IFrame)
        super
      else
        "#{@query_scope.selector_string} --> #{selector.inspect}"
      end
    end
  end # TextField

  module Container
    def text_field(*args)
      TextField.new(self, extract_selector(args).merge(tag_name: 'input'))
    end

    def text_fields(*args)
      TextFieldCollection.new(self, extract_selector(args).merge(tag_name: 'input'))
    end
  end # Container

  class TextFieldCollection < InputCollection
    private

    def element_class
      TextField
    end
  end # TextFieldCollection
end # Watir
