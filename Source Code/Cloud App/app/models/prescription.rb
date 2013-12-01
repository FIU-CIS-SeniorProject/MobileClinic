class Prescription < ActiveRecord::Base
  attr_accessible :instruction, :medId, :prescribedAt, :tabletsPerDay, :timeOfDay, :vistitId,:created_at,:updated_at


    self.primary_key = "vistitId"
    has_one :medication, :foreign_key => 'medId'
    
end
