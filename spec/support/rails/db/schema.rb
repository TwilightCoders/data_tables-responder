ActiveRecord::Schema.define do
  self.verbose = false

  enable_extension 'pgcrypto'
  enable_extension 'uuid-ossp'

  create_table :users, id: :uuid, :force => true do |t|
    t.string :email
    t.timestamps
  end

  create_table :posts, :force => true do |t|
    t.uuid :user_id
    t.string :title
    t.integer :views # for testing integers
    t.timestamps
  end

  create_table :comments, :force => true do |t|
    t.uuid :user_id
    t.integer :post_id
    t.timestamps
  end

end
