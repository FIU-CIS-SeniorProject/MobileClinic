class CreateMedications < ActiveRecord::Migration
  def change
    create_table :medications, {:primary_key => :medId} do |t|
      t.string   :dosage
      t.date     :expiration
      t.string   :medicationId
      t.string   :medName      
      t.integer  :numContainers
      t.integer  :tabletsContainer
      t.integer  :total
      t.integer  :status
      
      t.timestamps
    end
  end
end
