module DataTables
  module Modules
    class Pagination
      MissingSerializationContextError = Class.new(KeyError)
      FIRST_PAGE = 1

      attr_reader :collection, :context

      def initialize(collection, adapter_options)
        @collection = collection
        @adapter_options = adapter_options
        @context = adapter_options.fetch(:serialization_context) do
          fail MissingSerializationContextError, <<-EOF.freeze
  Datatables::Pagination requires a ActiveModelSerializers::SerializationContext.
  Please pass a ':serialization_context' option or
  override CollectionSerializer#paginated? to return 'false'.
           EOF
        end
      end

      def paginate
        start = (request_parameters[:start] || '0').to_i
        length = (request_parameters[:length] || '10').to_i
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

      def request_parameters
        @request_parameters ||= context.request_parameters
      end
    end
  end
end
