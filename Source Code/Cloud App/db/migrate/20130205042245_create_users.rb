class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, {:primary_key => :userid} do  |t|

      t.string  :userName, unique: true
      t.string  :password_digest
      t.string  :firstName
      t.string  :lastName
      t.string  :email , unique: true
      t.integer  :charityid
      t.string  :question
      t.string  :answer
      t.integer :userType
      t.integer :status
      t.integer :reset_password
      t.string  :remember_token

      t.timestamps
    end

  end
end