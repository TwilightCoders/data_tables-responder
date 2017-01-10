module DataTables
  module Modules
    class Search
      MissingSerializationContextError = Class.new(KeyError)

      attr_reader :collection, :context

      def initialize(collection, adapter_options)
        @collection = collection
        @adapter_options = adapter_options
        @context = adapter_options.fetch(:serialization_context) do
          fail MissingSerializationContextError, <<-EOF.freeze
  Datatables::Search requires a ActiveModelSerializers::SerializationContext.
  Please pass a ':serialization_context' option or
  override CollectionSerializer#searchable? to return 'false'.
           EOF
        end
      end

      def search
        default_search = request_parameters.dig(:search, :value)

        model = @collection.try(:model) || @collection
        arel_table = model.arel_table
        columns = searchable_columns(default_search)

        searches = DataTables.flat_keys_to_nested columns

        search_by = build_search(model, searches)

        @collection.where(search_by.reduce(:or))
      end

      def build_search(model, searches)
        queries = []
        searches.inject(queries) do |query, junk|
          column, search = junk
          case search
          when Hash
            assoc = model.reflect_on_association(column)
            assoc_klass = assoc.klass

            outer_join = Arel::Nodes::OuterJoin.new(assoc_klass.arel_table,
              Arel::Nodes::On.new(
                model.arel_table[assoc.foreign_key].eq(assoc_klass.arel_table[assoc.active_record_primary_key])
            ))
            query << build_search(assoc_klass, search).reduce(:or)
            @collection = @collection.joins(outer_join)
          else
            col_s = column.to_s
            case (k = model.columns.find(nil) { |c| c.name == col_s })&.type
            when :string
              query << model.arel_table[k.name].matches("%#{search}%")
            when :integer
              query << model.arel_table[k.name].eq(search)
            else
              query
            end
          end
        end
        queries
      end

      protected

      def searchable_columns(default_search)
        @searchable_columns = {}
        request_parameters[:columns]&.inject(@searchable_columns) do |a, b|
          if (b[:searchable] && b[:data].present?)
            if ((value = b.dig(:search, :value).present? ? b.dig(:search, :value) : default_search).present?)
              a[b[:data]] = value
            end
          end
          a
        end

        @searchable_columns
      end

      private

      def request_parameters
        @request_parameters ||= context.request_parameters
      end

    end
  end
end
