module DataTables
  module Arel
    module Predications
      def date_trunc(other)
        Nodes::DatePart.new self, other
