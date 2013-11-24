class CreateAppusers < ActiveRecord::Migration
  def change
    create_table :appusers, {:primary_key => :appuserid} do |t|
      
      t.string  :userName
      t.string  :password
      t.string  :firstName
      t.string  :lastName
      t.string  :email
      t.string  :charityid
      t.integer :userType
      t.integer :status

      t.timestamps
    end
  end
end
