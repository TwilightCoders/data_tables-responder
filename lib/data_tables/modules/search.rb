module DataTables
  module Modules
    class Search

      attr_reader :scope, :context

      def initialize(model, scope, params)
        @scope = scope.dup
        @model = model
        @params = params
      end

      def search
        columns = searchable_columns(@params.dig(:search, :value), @params[:columns])

        searches = DataTables::Responder.flat_keys_to_nested columns

        search_by, join_hash = build_search(@model, searches)

        @scope = @scope.joins(join_hash)

        @scope.where(search_by.reduce(:and))
      end

      def build_search(model, in_hash, join_hash = nil)
        # Tuple!
        return in_hash.inject([]) { |queries, (column, query)|
          case query
          when Hash
            if (assoc = model.reflect_on_association(column))
              new_queries, join_class = build_search(assoc.klass, query)

              join_hash = join_class.nil? ? [column] : {column => join_class}

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
        }, join_hash
      end

    protected

      def search_by_type(model, column, query, &block)
        arel_column = model.arel_table[column]
        result = case model.columns_hash[column.to_s]&.type
        when :string
          # I'm pretty sure this is safe from SQL Injection
          arel_column.matches("%#{query}%")
        when :integer
          value = query&.to_i and arel_column.eq(value)
        when :datetime
          datetime = Time.parse(query)
          range = (datetime-1.second)..(datetime+1.second)
          arel_column.between(range)
        when :uuid
          lower = query.gsub(/-/, '').ljust(32, '0')
          upper = query.gsub(/-/, '').ljust(32, 'f')
          arel_for_range(arel_column, (lower..upper))
        end

        yield(result) if !result.nil? && block_given?

        result
      end

      def searchable_columns(default_search, columns)
        columns&.inject({}) do |collection, column|
          if (column[:searchable] && column[:data].present?)
            if ((value = column.dig(:search, :value).present? ? column.dig(:search, :value) : default_search).present?)
              collection[column[:data]] = value
            end
          end
          collection
        end
      end

    private

      def arel_for_range(column, range)
        Arel::Nodes::Between.new(column, Arel::Nodes::And.new([
          Arel::Nodes::Casted.new(range.first, column),
          Arel::Nodes::Casted.new(range.last, column)
        ]))
      end

    end
  end
end
