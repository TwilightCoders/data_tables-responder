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
        return @collection unless (default_search = request_parameters.dig(:search, :value)).present?

        model = @collection.try(:model) || @collection
        arel_table = model.arel_table
        columns = searchable_columns(default_search)

        searches = DataTables.flat_keys_to_nested columns

        or_clause = nil
        search_by = searches.collect do |k, query|
          if query.is_a? Hash
            assoc = model.reflect_on_association(k)
            assoc_klass = assoc.klass
            assoc_arel_table = assoc_klass.arel_table

            if model.respond_to? :left_outer_join
              @collection = @collection.left_outer_join(k)
            else
              @collection = @collection.includes(k).references(k)
            end

            assoc_arel_table[query.first.first].matches(query.first.last)
          else
            if (column = model.columns.find { |c| c.name == k.to_s })
              case column.type
              when :string
                model.arel_table[k].matches("%#{query}%")
              else
                nil
              end
            end
          end
        end.compact

        @collection.where(search_by.reduce(:or))
      end

      protected

      def searchable_columns(default_search)
        @searchable_columns ||= Hash[
          request_parameters[:columns].collect do |c|
            if c[:searchable] && c[:data]
              value = default_search unless (value = c.dig(:search, :value)).present?
              [c[:data], value]
            else
              nil
            end
          end.compact
        ]
      end

      private

      def request_parameters
        @request_parameters ||= context.request_parameters
      end

    end
  end
end
