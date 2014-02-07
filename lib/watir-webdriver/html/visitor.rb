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
          *attribute_calls(attributes)
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

      def attribute_calls(attributes)
        attributes.map do |attribute|
          call(:attribute, [
            [:lit, ruby_type_for(attribute.type)],
            [:lit, ruby_method_name_for(attribute)],
            [:lit, attribute.name.to_sym]
          ])
        end
      end

      def call(name, args)
        [:call, nil, name.to_sym, [:arglist] + args]
      end

      def ruby_method_name_for(attribute)
        str = attribute.name.snake_case

        if attribute.type.name == :Boolean
          str = $1 if str =~ /^is_(.+)/
          str << '?'
        end

        str = 'for' if str == 'html_for'

        str.to_sym
      end

      def ruby_type_for(type)
        case type.name.to_s
        when 'DOMString', 'any'
          String
        when 'UnsignedLong', 'Long', 'Integer', 'Short', 'UnsignedShort'
          Fixnum
        when 'Float', /.*Double$/
          Float
        when 'Boolean'
          'Boolean'
        when 'WindowProxy', 'ValidityState', 'MediaError', 'TimeRanges', 'Location',
             'Any', 'TimedTrackArray', 'TimedTrack', 'TextTrackArray', 'TextTrack',
             'MediaController', 'TextTrackKind', 'Function', /.*EventHandler$/,
             'Document', 'DocumentFragment', 'DOMTokenList', 'DOMSettableTokenList',
             'DOMStringMap', 'HTMLPropertiesCollection', /HTML(.*)Element/, /HTML(.*)Collection/,
             'CSSStyleDeclaration',  /.+List$/, 'Date', 'Element'
          # probably completely wrong.
          String
        else
          raise "unknown type: #{type.name}"
        end
      end

    end # Visitor
  end # Support
end # Watir
