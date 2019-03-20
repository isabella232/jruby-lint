module JRuby::Lint::Checkers
  module CheckGemNode
    def self.add_wiki_link_finding(collector)
      unless @added_wiki_link
        collector.add_finding("For more on gem compatibility see http://wiki.jruby.org/C-Extension-Alternatives", [:gems, :info]).tap do |f|
          def f.to_s
            message
          end
        end
        @added_wiki_link = true
      end
    end

    def gem_name(node)
      first_arg = node&.args_node&.child_nodes[0]
      first_arg.value.to_s if first_arg&.node_type&.to_s == "STRNODE"
    end

    def check_gem(collector, call_node)
      @gems ||= collector.project.libraries.gems
      gem_name = gem_name(call_node)
      if instructions = @gems[gem_name]
        CheckGemNode.add_wiki_link_finding(collector)
        msg = "Found gem '#{gem_name}' which is reported to have some issues:\n#{instructions}"
        collector.add_finding(msg, [:gems, :warning], call_node.line+1)
      end
    end
  end

  class Gem
    include JRuby::Lint::Checker, CheckGemNode

    def visitFCallNode(node)
      check_gem(collector, node) if node.name == :gem
    end
  end
end
