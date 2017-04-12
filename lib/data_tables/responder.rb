require 'data_tables'
require "data_tables/responder/version"

require 'data_tables/modules/pagination'
require 'data_tables/modules/search'
require 'data_tables/modules/order'

require 'data_tables/active_model_serializers/adapter'
require 'data_tables/responder/railtie' if defined? ::Rails::Railtie

require 'quick_count'

module DataTables
  module Responder

    def self.respond(original_scope, params)
      model = original_scope.try(:model) || original_scope

      filtered_scope = original_scope&.dup || model.none

      filtered_scope = order(model, filtered_scope, params)

      filtered_scope = search(model, filtered_scope, params)

      filtered_scope = paginate(model, filtered_scope, params)
    end

    def self.flat_keys_to_nested(hash)
      hash.each_with_object({}) do |(key, value), all|
        key_parts = key.split('.').map!(&:to_sym)
        leaf = key_parts[0...-1].inject(all) { |h, k| h[k] ||= {} }
        leaf[key_parts.last] = value
      end
    end

    def self.paginate(model, filtered_scope, params)
      Modules::Pagination.new(model, filtered_scope, params).paginate
    end

    def self.search(model, filtered_scope, params)
      Modules::Search.new(model, filtered_scope, params).search
    end

    def self.order(model, filtered_scope, params)
      Modules::Order.new(model, filtered_scope, params).order
    end

  end
end
