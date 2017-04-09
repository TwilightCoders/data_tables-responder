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
            recordsTotal: records_total,
            recordsFiltered: records_filtered
          }
        end

        protected

        def records_filtered
          @records_filtered ||= get_records_filtered
        end

        def records_total
          @records_total ||= get_records_total
        end

        private

        def get_records_filtered
          to_filter = @collection.unscope(:limit, :offset)
          if !to_filter.respond_to?(:count_estimate) || records_total < 1_000_000
            to_filter.count(@collection.model.primary_key).to_i
          else
            to_filter.count_estimate.to_i
          end
        end

        def get_records_total
          count = @collection.model.quick_count
          if count < 1_000_000
            count = @collection.model.all.count(@collection.model.primary_key).to_i
          end

          count
        end

      end
    end
  end
end
