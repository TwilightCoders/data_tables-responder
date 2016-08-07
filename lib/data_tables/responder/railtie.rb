require 'rails'

module DataTables
  module Responder
    class Railtie < ::Rails::Railtie
      initializer "data_tables.configure", after: 'active_model_serializers.prepare_serialization_context' do
        Mime::Type.register_alias 'application/json', :dt, %w( text/plain text/x-json application/jsonrequest application/dt application/datatable )
      end
    end
  end
end
