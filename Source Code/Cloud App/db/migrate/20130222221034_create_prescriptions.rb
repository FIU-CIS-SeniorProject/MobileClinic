class CreatePrescriptions < ActiveRecord::Migration
  def change
    create_table :prescriptions, :id => false do |t|
      t.integer :prescribedAt
      t.integer :medId
      t.integer :tabletsPerDay
      t.string :timeOfDay
      t.string :instruction
      t.integer :vistitId
      t.timestamps
    end
  end
end
