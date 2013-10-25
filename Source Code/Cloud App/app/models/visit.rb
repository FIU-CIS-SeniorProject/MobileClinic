class Visit < ActiveRecord::Base

  attr_accessible   :bloodPressure, :conditions, :observation, :docterOut, :doctorId, 
                    :doctorIn, :doctorOut, :nurseId, :patientId, :triageIn, :triageOut, 
                    :weight, :diagnosisTitle, :heartRate, :respiration, :visitationId
  
  set_primary_key   :visitationId  
  belongs_to :patient, :foreign_key => 'patientId'
  belongs_to :user
  
  has_one :prescription
     
  end