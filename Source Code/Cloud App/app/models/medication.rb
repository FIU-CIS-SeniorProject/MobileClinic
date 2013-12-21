require 'csv'

class Medication < ActiveRecord::Base
  before_save { |medication| medication.medicationId = "#{medication.medName.downcase}_#{medication.dosage}"}
  before_save { |medication| medication.total = medication.numContainers*medication.tabletsContainer}

  attr_accessible :dosage,:expiration,:medicationId,:medName,:numContainers,:tabletsContainer,:total,:status

  validates :dosage,  :presence => true
  validates :status,  :presence => true
  validates :expiration, :presence => true
  validates_presence_of :medName
  validates_uniqueness_of :medName, :case_sensitive => false, conditions: -> { where.not(status: 0) }
  validates :numContainers,  :presence => true, :numericality => true
  validates :tabletsContainer,  :presence => true, :numericality => true

  self.primary_key = "medId"
  has_many :prescriptions, :foreign_key => 'medicationId'

  def  self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["Medication ID", "Name", "Number of Containers","Tablets per Container","Dosage","Total","Expiration","Status"]
      all.each do |medication|
        if medication.status == 0
        csv << [medication.medicationId, medication.medName, medication.numContainers,
           medication.tabletsContainer,medication.dosage,medication.total,
           medication.expiration.strftime("%m/%d/%Y"),"Inactive"]
       else
         csv << [medication.medicationId, medication.medName, medication.numContainers,
           medication.tabletsContainer,medication.dosage,medication.total,
           medication.expiration.strftime("%m/%d/%Y"),"Active"]
       end
      end
    end
  end
end

