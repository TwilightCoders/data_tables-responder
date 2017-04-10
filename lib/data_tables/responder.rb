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

      filtered_scope = original_scope&.dup || model.none
      hashed_orders = transmute_datatable_order(params[:order], params[:columns])
      orders = flat_keys_to_nested hashed_orders

      order_by, filtered_scope = build_order_map(model, orders, filtered_scope)

      filtered_scope = search(filtered_scope, params)

      # Rails.logger.warn "SEARCH BY: #{search_by}"
      filtered_scope = order_by.inject(filtered_scope) { |r, o| r.order(o) }
      filtered_scope = paginate(original_scope, filtered_scope, params)
    end

    def self.flat_keys_to_nested(hash)
      hash.each_with_object({}) do |(key, value), all|
        key_parts = key.split('.').map!(&:to_sym)
        leaf = key_parts[0...-1].inject(all) { |h, k| h[k] ||= {} }
        leaf[key_parts.last] = value
      end
    end

    def self.paginate(original_scope, filtered_scope, params)
      Modules::Pagination.new(original_scope, filtered_scope, params).paginate
    end

    def self.search(filtered_scope, params)
      Modules::Search.new(filtered_scope, params).search
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

    def self.build_order_map(model, in_hash, filtered_scope)
      # Tuple!
      return in_hash.inject([]) { |sum, (k, h)|
        case h
        when Hash
          if (klass = model.reflect_on_association(k).try(:klass))
            new_sum, filtered_scope = build_order_map(klass, h, filtered_scope.merge(model.joins(k)))
            sum += new_sum
          else
            warn("trying to reflect on #{k} but #{model.class.name} has no such association.")
          end
        else
          sum << model.arel_table[k].send(h) if model.column_names.include?(k.to_s)
        end
        sum
      }, filtered_scope
    end

  end
end
