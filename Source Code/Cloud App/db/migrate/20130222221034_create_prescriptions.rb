class CreatePrescriptions < ActiveRecord::Migration
  def change
    create_table :prescriptions, :id => false do |t|
      t.string  :instructions
      t.string  :medicationId
      t.string  :medName
      t.string  :prescribedTime
	    t.string  :prescriptionId
	    t.string  :timeOfDay
	    t.string  :visitationId
      t.integer :tabletPerDay
      t.integer :charityid
	    
      t.timestamps
    end
  end
end
