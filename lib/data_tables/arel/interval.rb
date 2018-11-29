# frozen_string_literal: true
module Arel
  module Nodes
    Interval = Class.new(::Arel::Nodes::Binary)

    module IntervalVisitor
      def visit_Arel_Nodes_Interval o, collector
        collector << " INTERVAL "
        visit(o.right, visit(o.left, collector) << " ")
      end
    end

  end
end

Arel::Visitors::ToSql.include Arel::Nodes::IntervalVisitor
