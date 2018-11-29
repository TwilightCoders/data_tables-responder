module DataTables
  module DatabaseStatements
    module PostgreSQL

      def self.date_parts
        [:year, :month, :day, :hour, :minute, :second, :microsecond]
      end

      def self.sanity_check_date_part(part)
        date_parts.find { |p| p == part.to_sym } ||
        DataTables::DatabaseStatements::PostgreSQL.date_parts.last
      end

      def partial_date(precision, attribute)
        precision = DataTables::DatabaseStatements::PostgreSQL.sanity_check_date_part(precision)
        func = Arel::Nodes::NamedFunction.new('date_trunc', [Arel::Nodes::Quoted.new(precision.to_s), attribute])
      end
    end
  end
end
