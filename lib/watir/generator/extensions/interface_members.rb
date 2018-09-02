module WebIDL
  module ParseTree
    class InterfaceMembers < Treetop::Runtime::SyntaxNode

      def build(parent)
        m = member.build(parent)

        # For some reason WebIDL::Ast::Operation & WebIDL::Ast::Const have eal
        # but do not respond to :extended_attributes
        if m.is_a?(WebIDL::Ast::Attribute) && eal.any?
          m.extended_attributes = eal.build(parent)
        end

        list = [m]
        list += members.build(parent) unless members.empty?

        if parent
          parent.members = list
        end

        list
      end

    end # InterfaceMembers
  end # ParseTree
end # WebIDL