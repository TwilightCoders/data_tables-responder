module DataTables
  module Modules
    class Order

      attr_reader :scope, :context

      def initialize(scope, request_parameters)
        @scope = scope.dup
        @request_parameters = request_parameters
      end

      def order
        # default_order = @request_parameters.dig(:order, :value)

        model = @scope.try(:model) || @scope
        columns = orderable_columns(@request_parameters[:order], @request_parameters[:columns])

        orders = DataTables::Responder.flat_keys_to_nested columns

        order_by, join_hash = build_order(model, orders)

        @scope = @scope.joins(join_hash)

        order_by.inject(@scope) { |r, o| r.order(o) }
      end

      def build_order(model, in_hash, join_hash = nil)
        # Tuple!
        return in_hash.inject([]) { |sum, (k, h)|
          case h
          when Hash
            if (klass = model.reflect_on_association(k).try(:klass))

              new_sum, join_class = build_order(klass, h)

              join_hash = join_class.nil? ? [k] : {k => join_class}

              sum += new_sum
            else
              warn("trying to reflect on #{k} but #{model.class.name} has no such association.")
            end
          else
            sum << model.arel_table[k].send(h) if model.column_names.include?(k.to_s)
          end
          sum
        }, join_hash
      end

      protected

      def orderable_columns(orders, columns)
        sums = {}
        (orders || []).inject(sums) do |sum, order|
          if (name = columns[order[:column]][:data]).present?
            sum[name] = order[:dir]
          end
        end
        sums
      end

    end
  end
end
