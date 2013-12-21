require 'csv'

class Patient < ActiveRecord::Base
  
  attr_accessible :age, :firstName, :familyName, :sex, :villageName, :label, :patientId,:created_at,:updated_at

  self.primary_key = "patientId"
  
  def visitFeed
    Visits.from_patients_my_visits(self)
  end
  def name
    [firstName, familyName].join " "
  end
  
  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["Patient ID","First Name", "Family Name", "Village","Gender","Age","Created Date","Updated Date"]
      all.each do |patient|
        if patient.sex == 1
        csv << [patient.patientId, patient.firstName, patient.familyName,
           patient.villageName,"Male",
           Time.now.year - Time.at(patient.age).year - (Time.at(patient.age).to_time.change(:year => Time.now.year) > Time.now ? 1 : 0),
           patient.created_at.strftime("%m/%d/%Y"),patient.updated_at.strftime("%m/%d/%Y")]
       else
         csv << [patient.patientId, patient.firstName, patient.familyName,
           patient.villageName,"Female",
           Time.now.year - Time.at(patient.age).year - (Time.at(patient.age).to_time.change(:year => Time.now.year) > Time.now ? 1 : 0),
           patient.created_at.strftime("%m/%d/%Y"),patient.updated_at.strftime("%m/%d/%Y")]
       end
      end
    end
  end
end