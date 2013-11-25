class CreateUserTokens < ActiveRecord::Migration
  def change
    create_table :auths, :id => false do |t|
      t.integer :user_id
      t.string :user_token
      t.string :expiration
      t.string :access_token
      t.timestamps
    end
  end
end
