class Prescription < ActiveRecord::Base
  attr_accessible :visitationId, :medicationId, :charityid, :instructions, 
  :medName, :prescribedTime,:timeOfDay,:tabletPerDay,:prescriptionId,:created_at,:updated_at

  self.primary_key = "prescriptionId"
end
