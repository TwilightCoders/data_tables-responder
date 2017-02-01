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
        page = (start / length)
        @filtered_scope = @filtered_scope.offset(page * length).limit(length)
      end

    end
  end
end
