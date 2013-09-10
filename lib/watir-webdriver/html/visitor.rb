# encoding: utf-8

module Watir
  module HTML
    class Visitor < WebIDL::RubySexpVisitor

      def initialize
        super

        # When an interface has multiple IDL definitions in the spec, the inheritance is sometimes
        # not repeated. So we'll keep track ourselves.
        @inheritance_map = {}

        @already_defined = []
      end

      #
      # WebIDL visitor interface
      #

      def visit_interface(interface)
        name   = interface.name
        parent = interface.inherits.first

        $stderr.puts name
        return unless name =~ /^HTML/ && name !~ /(Collection|Document)$/

        if name == "HTMLElement"
          parent = 'Element'
        elsif parent
          @inheritance_map[name] ||= parent.name
          parent = parent.name
        else
          parent = @inheritance_map[name] || return
        end

        [ :scope,
          [:block,
            element_class(interface.name, extract_attributes(interface), parent),
            collection_class(interface.name)
          ]
        ]
      end

      def visit_module(mod)
        # ignored
      end

      def visit_implements_statement(stmt)
        # ignored
      end

      # TODO: do everything in the visitor somehow?
      # problem is we lack the tag name info while walking the interface AST
      # #
      # # Watir generator visitor interface
      # #
      #
      # def visit_tag(tag_name, interface_name)
      #   tag_string       = tag.inspect
      #   singular         = Util.paramify(tag)
      #   plural           = singular.pluralize
      #   element_class    = Util.classify(interfaces.first.name)
      #   collection_class = "#{element_class}Collection"
      #
      #   [:defn,
      #    :a,
      #    [:args, :"*args"],
      #    [:scope,
      #     [:block,
      #      [:call,
      #       [:const, :Anchor],
      #       :new,
      #       [:arglist,
      #        [:self],
      #        [:call,
      #         [:call, nil, :extract_selector, [:arglist, [:lvar, :args]]],
      #         :merge,
      #         [:arglist, [:hash, [:lit, :tag_name], [:str, "a"]]]]]]]]]
      # end

      private

      def element_class(name, attributes, parent)
        [:class, Util.classify(name), [:const, Util.classify(parent)],
          [:scope,
            [:block, attributes_call(attributes)]
          ]
        ]
      end

      def extract_attributes(interface)
        members = interface.members
        members += interface.implements.flat_map(&:members)

        members.select { |e| e.kind_of?(WebIDL::Ast::Attribute) }
      end

      def collection_class(name)
        return if @already_defined.include?(name)
        @already_defined << name
        name = Util.classify(name)

        [:class, "#{name}Collection", [:const, :ElementCollection],
          [:scope,
            [:defn, :element_class,
              [:args],
              [:scope,
                [:block, [:const, name]]
              ]
            ]
          ]
        ]
      end

      def attributes_call(attributes)
        return if attributes.empty?

        attrs = Hash.new { |hash, key| hash[key] = [] }
        attributes.sort_by { |a| a.name }.each do |a|
          type = ruby_type_for(a.type)
          attrs[type] << ruby_attribute_for(type, a.name)
        end

        call :attributes, [literal_hash(attrs)]
      end

      def ruby_attribute_for(type, str)
        str = str.snake_case

        if str =~ /^is_(.+)/ && type == :bool
          str = $1
        end

        str.to_sym
      end

      def literal_hash(hash)
        [:hash] + hash.map { |k, v| [[:lit, k.to_sym], [:lit, v]] }.flatten(1)
      end

      def literal_array(arr)
        [:array] + arr.map { |e| [:lit, e.to_sym] }
      end

      def call(name, args)
        [:call, nil, name.to_sym, [:arglist] + args]
      end

      def ruby_type_for(type)
        case type.name.to_s
        when 'DOMString', 'any'
          :string
        when 'UnsignedLong', 'Long', 'Integer', 'Short', 'UnsignedShort'
          :int
        when 'Float', /.*Double$/
          :float
        when 'Function', /.*EventHandler$/
          :function
        when 'Boolean'
          :bool
        when 'Document', 'DocumentFragment'
          :document
        when 'DOMTokenList', 'DOMSettableTokenList'
          :token_list
        when 'DOMStringMap'
          :string_map
        when 'HTMLPropertiesCollection'
          :properties_collection
        when /HTML(.*)Element/
          :html_element
        when /HTML(.*)Collection/
          :html_collection
        when 'CSSStyleDeclaration'
          :style
        when /.+List$/
          :list
        when 'Date'
          :date
        when 'Element'
          :element
        when 'WindowProxy', 'ValidityState', 'MediaError', 'TimeRanges', 'Location',
             'Any', 'TimedTrackArray', 'TimedTrack', 'TextTrackArray', 'TextTrack',
             'MediaController', 'TextTrackKind'
          # probably completely wrong.
          :string
        else
          raise "unknown type: #{type.name}"
        end
      end

    end # Visitor
  end # Support
end # Watir
