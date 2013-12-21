class Visit < ActiveRecord::Base

  attr_accessible   :assessment, :bloodPressure, :charityid, :condition, :conditionTitle, :diagnosisTitle, :doctorId,
                    :doctorIn, :doctorOut, :heartRate, :medicationNotes, :nurseId, :observation,
                    :patientId,:respiration,:temperature,:triageIn,:triageOut,:visitationId,
                    :weight, :created_at,:updated_at

  self.primary_key = "visitationId"
end