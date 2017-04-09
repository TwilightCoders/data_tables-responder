require 'data_tables'
require "data_tables/responder/version"

require 'data_tables/modules/pagination'
require 'data_tables/modules/search'

require 'data_tables/active_model_serializers/adapter'
require 'data_tables/responder/railtie' if defined? ::Rails::Railtie

module DataTables
  module Responder

    def self.respond(original_scope, params)
      model = original_scope.try(:model) || original_scope

      filtered_results = original_scope&.dup || model.none
      hashed_orders = transmute_datatable_order(params[:order], params[:columns])
      orders = flat_keys_to_nested hashed_orders

      order_by = build_order_map(model, orders)#, filtered_results)

      filtered_results = search(filtered_results, params)

      # Rails.logger.warn "SEARCH BY: #{search_by}"
      filtered_results = order_by.inject(filtered_results) { |r, o| r.order(o) }
      filtered_results = paginate(original_scope, filtered_results, params)
    end

    def self.flat_keys_to_nested(hash)
      hash.each_with_object({}) do |(key, value), all|
        key_parts = key.split('.').map!(&:to_sym)
        leaf = key_parts[0...-1].inject(all) { |h, k| h[k] ||= {} }
        leaf[key_parts.last] = value
      end
    end

    def self.paginate(original_scope, filtered_results, params)
      Modules::Pagination.new(original_scope, filtered_results, params).paginate
    end

    def self.search(filtered_results, params)
      Modules::Search.new(filtered_results, params).search
    end

    def self.transmute_datatable_order(orders, columns)
      sums = {}
      (orders || []).inject(sums) do |sum, order|
        if (name = columns[order[:column]][:data]).present?
          sum[name] = order[:dir]
        end
      end
      sums
    end

    private

    def self.build_order_map(model, in_hash)#, filtered_results)
      results = []
      in_hash.inject(results) do |sum, (k, h)|
        case h
        when Hash
          if (klass = model.reflect_on_association(k).try(:klass))
            # filtered_results = filtered_results.joins(k)
            sum += build_order_map(klass, h)#, filtered_results)
          else
            warn("trying to reflect on #{k} but #{model.class.name} has no such association.")
          end
        else
          sum << model.arel_table[k].send(h) if model.column_names.include?(k.to_s)
        end
        return sum
      end
      results
    end

  end
end
