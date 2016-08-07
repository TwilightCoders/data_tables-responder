require 'active_model_serializers'
require 'data_tables/modules/pagination'
require 'data_tables/modules/search'

module DataTables
  def self.flat_keys_to_nested(hash)
    hash.each_with_object({}) do |(key, value), all|
      key_parts = key.split('.').map!(&:to_sym)
      leaf = key_parts[0...-1].inject(all) { |h, k| h[k] ||= {} }
      leaf[key_parts.last] = value
    end
  end

  class Adapter < ::ActiveModelSerializers::Adapter::Base

    def serializable_hash(options)
      options = serialization_options(options)
      @serialization_context = options[:serialization_context]

      collection = serializer.object

      params = @serialization_context.request_parameters
      model = collection.try(:model) || collection

      @results = collection
      hashed_orders = transmute_datatable_order(params[:order], params[:columns])
      orders = DataTables.flat_keys_to_nested hashed_orders

      order_by = orders.collect do |k, order|
        if order.is_a? Hash
          if (klass = model.reflect_on_association(k).try(:klass))
            @results = @results.joins(k)
            klass.arel_table[order.first.first].send(order.first.last)
          end
        else
          { k => order }
        end
      end

      @results = search(@results)
      # search_by = search(@results)

      # Rails.logger.warn "SEARCH BY: #{search_by}"
      @results = order_by.inject(@results) { |r, o| r.order(o) }
      @results = paginate(@results)

      new_serializer = serializer.class.new(@results, serializer.instance_variable_get(:@options))
      serialized_hash = {
        data: ::ActiveModelSerializers::Adapter::Attributes.new(new_serializer, instance_options).serializable_hash(options)
      }
      serialized_hash[meta_key] = meta unless meta.blank?
      serialized_hash.merge!(@pagination.as_json) unless @pagination.blank?

      self.class.transform_key_casing!(serialized_hash, instance_options)
      # binding.pry
    end

    def reformatted_columns(params)
      # binding.pry
      params[:columns]
    end

    protected

    def paginate(collection)
      @pagination ||= Modules::Pagination.new(collection, instance_options)
      collection = @pagination.paginate
    end

    def search(collection)
      @search ||= Modules::Search.new(collection, instance_options)
      collection = @search.search
    end

    def transmute_datatable_order(orders, columns)
      Hash[if orders.is_a? Array
        orders.collect do |order|
          if (name = columns[order[:column]][:data]).present?
            [name, order[:dir]]
          else
            nil
          end
        end
      else
        []
      end.compact]
    end

    def meta
      {
        sql: @results.to_sql
      }.merge(instance_options.fetch(:meta, {}))
    end

    def meta_key
      instance_options.fetch(:meta_key, 'meta'.freeze)
    end

  end
end
