module DataTables
  module ActiveModelSerializers
    class Adapter
      class Pagination

        attr_reader :collection

        def initialize(serializer)
          @collection = serializer.object
        end

        def as_h
          {
            recordsTotal: collection&.total_entries&.to_i,
            recordsFiltered: @collection&.unscope(:limit, :offset)&.count_estimate&.to_i
          }
        end

      end
    end
  end
end
