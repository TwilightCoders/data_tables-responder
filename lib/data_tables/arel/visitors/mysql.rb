module DataTables
  module Arel
    module Visitors
      module MySQL
        def visit_Arel_Nodes_DatePart o, collector
          Nodes::NamedFunction.new('date_add', [''])
          collector << "DATE_ADD('1900-01-01', INTERVAL TIMESTAMPDIFF("
          collector << o.right.visit(MINUTE
          collector << "'1900-01-01', `posts`.`created_at`) MINUTE)"

          collector << " INTERVAL "
          visit(o.right, visit(o.left, collector) << " ")
        end
      end
    end
  end
end
