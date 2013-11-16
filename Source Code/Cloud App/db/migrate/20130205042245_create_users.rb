class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, :id => false do  |t|
      
      t.string :userName, unique: true
      t.string :password_digest
      t.string :firstName
      t.string :lastName
      t.string :email , unique: true
      t.integer :userType
      t.integer :status
      t.string :remember_token

      t.timestamps
    end
    
  end
end