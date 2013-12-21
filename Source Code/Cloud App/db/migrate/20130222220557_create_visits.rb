class CreateVisits < ActiveRecord::Migration
  def change
    create_table :visits, :id => false do |t|
      t.string  :assessment
      t.string  :bloodPressure
      t.integer :charityid
      t.string  :condition
      t.string  :conditionTitle
      t.string  :diagnosisTitle
      t.string  :doctorId
      t.integer :doctorIn
      t.integer :doctorOut
      t.string  :heartRate 
      t.string  :medicationNotes 
      t.string  :nurseId 
      t.string  :observation
      t.string  :patientId
      t.string  :respiration 
      t.string  :temperature 
      t.integer :triageIn
      t.integer :triageOut
      t.string  :visitationId
      t.float   :weight
            
      t.timestamps
    end
  end
end