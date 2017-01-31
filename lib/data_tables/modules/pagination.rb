require 'count_estimate'

module DataTables
  module Modules
    class Pagination
      FIRST_PAGE = 1

      attr_reader :original_scope, :filtered_scope, :context

      def initialize(original_scope, filtered_scope, request_parameters)
        @original_scope = original_scope
        @filtered_scope = filtered_scope
        @request_parameters = request_parameters
      end

      def paginate
        start = (@request_parameters[:start] || '0').to_i
        length = (@request_parameters[:length] || '10').to_i
        page = (start / length) + 1
        @filtered_scope = @filtered_scope.paginate(page: page, per_page: length, total_entries: records_total)
      end

      def as_json
        {
          recordsTotal: @filtered_scope&.total_entries&.to_i,
          recordsFiltered: records_filtered&.to_i
        }
      end

      protected

      def records_total
        # TODO: Check threshold
        count_estimate = @original_scope&.model&.all&.count_estimate.to_i
        if count_estimate < 1_000_000
          count_estimate = @original_scope&.count
        end

        count_estimate
      end

      def records_filtered
        @filtered_scope&.unscope(:limit, :offset)&.count_estimate
      end

      attr_reader :adapter_options

      private

    end
  end
end
