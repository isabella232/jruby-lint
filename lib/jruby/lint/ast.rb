module JRuby::Lint
  module AST
    class Visitor
      include Enumerable
      include org.jruby.ast.visitor.NodeVisitor
      attr_reader :ast

      def initialize(ast)
        @ast = ast
      end

      def each(&block)
        @block = block
        ast.accept(self)
      ensure
        @block = nil
      end

      alias each_node each

      def visit(node)
        @block.call(node) if @block
        node.child_nodes.each do |cn|
          cn.accept(self)
        end
      end

      def method_missing(name, *args, &block)
        if name.to_s =~ /^visit/
          visit(*args)
        else
          super
        end
      end
    end
  end
end