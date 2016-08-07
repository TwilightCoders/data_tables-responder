require "data_tables/responder/version"
# Monkey-patch :/
require "data_tables/monkey_patch/active_model_serializers/serialization_context"

require 'data_tables/adapter'
require 'data_tables/responder/railtie' if defined? ::Rails::Railtie

module DataTables
  module Responder
  end
end
