class CreateMedications < ActiveRecord::Migration
  def change
    create_table :medications, {:primary_key => :medId} do |t|
      t.string  :name
      t.integer :numContainers
      t.integer :tabletsPerContainer
      t.date    :expiration
      t.integer :doseOfTablets
      t.integer :status
      t.timestamps
    end
  end
end
