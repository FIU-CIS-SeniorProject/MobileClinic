class CreateVisits < ActiveRecord::Migration
  def change
    create_table :visits, :id => false do |t|
      t.integer :triageIn
      t.float :weight
      t.string :diagnosisTitle
      t.text :conditions
      t.string :bloodPressure
      t.integer :triageOut
      t.integer :doctorIn
      t.integer :doctorOut
      t.string :doctorId
      t.string :nurseId
      t.string :patientId
      t.text :observation
      t.string :heartRate 
      t.string :respiration 
      t.string :visitationId

      t.timestamps
    end
  end
end