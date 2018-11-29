module DataTables
  module Arel
    module Visitors
      module PostgreSQL
        def visit_Arel_Nodes_DatePart o, collector
          collector << " INTERVAL "
          visit(o.right, visit(o.left, collector) << " ")
        end
      end
    end
  end
end
