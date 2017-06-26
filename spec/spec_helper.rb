ENV["RAILS_ENV"] = "test"

require 'database_cleaner'

require 'data_tables/responder'

Dir[DataTables.root.join('spec/support/**/*.rb')].each { |f| require f }

db_config = {
  adapter: "postgresql", database: "data_tables_test"
}

db_config_admin = db_config.merge({ database: 'postgres', schema_search_path: 'public' })

ActiveRecord::Base.establish_connection db_config_admin
ActiveRecord::Base.connection.drop_database(db_config[:database])
ActiveRecord::Base.connection.create_database(db_config[:database])
ActiveRecord::Base.establish_connection db_config

load File.dirname(__FILE__) + '/schema.rb'

RSpec.configure do |config|
  config.order = "random"

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation, except: [])
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
