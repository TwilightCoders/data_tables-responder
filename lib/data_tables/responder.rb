require "data_tables/responder/version"

require 'data_tables/modules/pagination'
require 'data_tables/modules/search'

require 'data_tables/active_model_serializers/adapter'
require 'data_tables/responder/railtie' if defined? ::Rails::Railtie

module DataTables
  module Responder

    def self.respond(resource, params)
      model = resource.try(:model) || resource

      results = resource
      hashed_orders = transmute_datatable_order(params[:order], params[:columns])
      orders = flat_keys_to_nested hashed_orders

      order_by = orders.collect do |k, order|
        if order.is_a? Hash
          if (klass = model.reflect_on_association(k).try(:klass))
            results = results.joins(k)
            klass.arel_table[order.first.first].send(order.first.last)
          end
        else
          { k => order }
        end
      end

      results = search(results, params)

      # Rails.logger.warn "SEARCH BY: #{search_by}"
      results = order_by.inject(results) { |r, o| r.order(o) }
      results = paginate(results, params)
    end

    def self.flat_keys_to_nested(hash)
      hash.each_with_object({}) do |(key, value), all|
        key_parts = key.split('.').map!(&:to_sym)
        leaf = key_parts[0...-1].inject(all) { |h, k| h[k] ||= {} }
        leaf[key_parts.last] = value
      end
    end


    def self.paginate(collection, params)
      Modules::Pagination.new(collection, params).paginate
    end

    def self.search(collection, params)
      Modules::Search.new(collection, params).search
    end

    def self.transmute_datatable_order(orders, columns)
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
  end
end
