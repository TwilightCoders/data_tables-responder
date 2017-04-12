
module DataTables
  module Modules
    class Pagination

      FIRST_PAGE = '0'
      DEFAULT_LENGTH = '10'

      attr_reader :scope, :context

      def initialize(model, scope, params)
        @scope = scope.dup
        @model = model
        @params = params
      end

      def paginate
        start = (@params[:start] || FIRST_PAGE).to_i
        length = (@params[:length] || DEFAULT_LENGTH).to_i
        page = (start / length)
        @scope.offset(page * length).limit(length)
      end

    end
  end
end
