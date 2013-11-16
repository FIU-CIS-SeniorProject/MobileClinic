class Prescription < ActiveRecord::Base
  attr_accessible :instruction, :medId, :prescribedAt, :tabletsPerDay, :timeOfDay, :vistitId


    set_primary_key :vistitId
    has_one :medication, :foreign_key => 'medId'
    
end
