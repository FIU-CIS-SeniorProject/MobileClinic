class CreateMedications < ActiveRecord::Migration
  def change
    create_table :medications, :id => false do |t|
      t.integer :medId
      t.string :name
      t.integer :numContainers
      t.integer :tabletsPerContainer
      t.integer :expiration
      t.integer :doseOfTablets
      t.timestamps
    end
  end
end
