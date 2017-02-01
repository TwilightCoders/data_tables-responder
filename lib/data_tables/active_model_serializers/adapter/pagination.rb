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
          if records_total < 1_000_000
            @collection.unscope(:limit, :offset).count(@collection.model.primary_key).to_i
          else
            @collection.unscope(:limit, :offset).count_estimate.to_i
          end
        end

        def get_records_total
          count = @collection.model.all.count_estimate.to_i
          if count < 1_000_000
            count = @collection.model.all.count(@collection.model.primary_key).to_i
          end

          count
        end

      end
    end
  end
end
