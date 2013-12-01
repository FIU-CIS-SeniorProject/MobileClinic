require 'csv'    
class Medication < ActiveRecord::Base

	attr_accessible :doseOfTablets, :expiration, :name, :numContainers, :tabletsPerContainer, :notes, 
	                 :medId,:status,:created_at,:updated_at
	
	validates :doseOfTablets,  :presence => true, :numericality => true
	validates :status,  :presence => true
	validates :expiration, :presence => true
	validates :name, :presence => true
	validates :numContainers,  :presence => true, :numericality => true
	validates :tabletsPerContainer,  :presence => true, :numericality => true

	self.primary_key = "medId"
	has_many :prescriptions, :foreign_key => 'medId'

	def  self.to_csv(options = {})
		CSV.generate(options) do |csv|
			csv << column_names
			all.each do |medication|
				csv << medication.attributes.values_at(*column_names)
			end
		end
	end
end

