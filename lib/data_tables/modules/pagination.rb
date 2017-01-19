require 'count_estimate'

module DataTables
  module Modules
    class Pagination
      FIRST_PAGE = 1

      attr_reader :collection, :context

      def initialize(collection, request_parameters)
        @collection = collection
        @request_parameters = request_parameters
      end

      def paginate
        start = (@request_parameters[:start] || '0').to_i
        length = (@request_parameters[:length] || '10').to_i
        page = (start / length) + 1
        @collection = @collection.paginate(page: page, per_page: length, total_entries: records_total)
      end

      def as_json
        {
          recordsTotal: @collection&.total_entries&.to_i,
          recordsFiltered: records_filtered&.to_i
        }
      end

      protected

      def records_total
        @collection&.model&.all.count_estimate
      end

      def records_filtered
        @collection&.unscope(:limit, :offset)&.count_estimate
      end

      attr_reader :adapter_options

      private

    end
  end
end
