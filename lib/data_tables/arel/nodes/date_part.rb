module DataTables
  module Arel
    module Nodes
      class DatePart < Binary
        def visit_Arel_Nodes_Interval o, collector
          collector << " INTERVAL "
          visit(o.right, visit(o.left, collector) << " ")
        end
      end
    end
  end
end
