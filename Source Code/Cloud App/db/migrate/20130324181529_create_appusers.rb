class CreateAppusers < ActiveRecord::Migration
  def change
    create_table :appusers, :id => false do |t|
      
      t.string :userName
      t.string :password
      t.string :firstName
      t.string :lastName
      t.string :email
      t.integer :userType
      t.integer :status
      t.integer :secondaryTypes

      t.timestamps
    end
  end
end
