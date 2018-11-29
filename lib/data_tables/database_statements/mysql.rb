module DataTables
  module DatabaseStatements
    module MySQL

      def self.date_parts
        [:year, :month, :day, :hour, :minute, :second, :microsecond]
      end

      def self.sanity_check_date_part(part)
        date_parts.find { |p| p == part.to_sym } ||
        DataTables::DatabaseStatements::MySQL.date_parts.last
      end

      def self.epoch
        Arel::Nodes::Quoted.new('1900-01-01')
      end

      def self.timestamp(precision, attribute)
        Arel::Nodes::NamedFunction.new('TIMESTAMPDIFF', [precision, epoch, attribute])
      end

      def self.interval(precision, attribute)
        Arel::Nodes::Interval.new(timestamp(precision, attribute), precision)
      end

      def self.date_add(precision, attribute)
        Arel::Nodes::NamedFunction.new('DATE_ADD', [epoch, interval(precision, attribute)])
      end

      def self.partial_date(precision, attribute)
        precision = Arel::Nodes::SqlLiteral.new(sanity_check_date_part(precision).upcase.to_s)
        date_add(precision, attribute)
      end

      def partial_date(precision, attribute)
        DataTables::DatabaseStatements::MySQL.partial_date(precision, attribute)
      end
    end
  end
end
