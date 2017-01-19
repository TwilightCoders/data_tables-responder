require 'rails/railtie'
require 'action_controller'
require 'action_controller/railtie'

module DataTables
  module Responder
    class Railtie < ::Rails::Railtie

      initializer 'data_tables-responder.action_controller', after: 'active_model_serializers.action_controller' do
        ActiveSupport.on_load(:action_controller) do
          require 'data_tables/active_model_serializers/register_dt_renderer'
        end
      end

    end
  end
end
