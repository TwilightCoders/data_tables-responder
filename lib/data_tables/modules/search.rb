module DataTables
  module Modules
    class Search

      attr_reader :collection, :context

      def initialize(collection, request_parameters)
        @collection = collection
        @request_parameters = request_parameters
      end

      def search
        default_search = @request_parameters.dig(:search, :value)

        model = @collection.try(:model) || @collection
        columns = searchable_columns(default_search)

        searches = DataTables::Responder.flat_keys_to_nested columns

        search_by, @collection = build_search(model, searches, @collection)

        @collection.where(search_by.reduce(:and))
      end

      def build_search(model, in_hash, filtered_scope)
        # Tuple!
        return in_hash.inject([]) { |queries, (column, query)|
          case query
          when Hash
            if (assoc = model.reflect_on_association(column))
              new_queries, filtered_scope = build_search(assoc.klass, query, filtered_scope.merge(model.joins(column)))
              queries << new_queries.reduce(:and)
            else
              warn("trying to reflect on #{column} but #{model.class.name} has no such association.")
            end
          else
            search_by_type(model, column, query) do |result|
              queries << result
            end
          end
          queries
        }, filtered_scope
      end

      protected

      def search_by_type(model, column, query, &block)
        result = case model.columns_hash[column.to_s]&.type
        when :string
          # I'm pretty sure this is safe from SQL Injection
          model.arel_table[column].matches("%#{query}%")
        when :integer
          model.arel_table[column].eq(value) if value = query&.to_i
        when :datetime
          datetime = Time.parse(query)
          range = (datetime-1.second)..(datetime+1.second)
          model.arel_table[column].between(range)
        end

        yield(result) if !result.nil? && block_given?

        result
      end

      def searchable_columns(default_search)
        @searchable_columns = {}
        @request_parameters[:columns]&.inject(@searchable_columns) do |a, b|
          if (b[:searchable] && b[:data].present?)
            if ((value = b.dig(:search, :value).present? ? b.dig(:search, :value) : default_search).present?)
              a[b[:data]] = value
            end
          end
          a
        end

        @searchable_columns
      end

    end
  end
end
