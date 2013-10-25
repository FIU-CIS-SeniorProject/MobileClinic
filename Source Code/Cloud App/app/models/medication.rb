require 'csv'    
class Medication < ActiveRecord::Base
	before_save { |med| med.medId = create_med_id(med.name)}

	attr_accessible :doseOfTablets, :expiration, :name, :numContainers, :tabletsPerContainer, :notes
	# validates :medId, :uniqueness => true, :numericality => true, length:  { minimum: 3, maximum: 10}
	validates  :doseOfTablets,  :presence => true, :numericality => true
	validates  :expiration, :presence => true
	validates  :name, :presence => true
	validates :numContainers,  :presence => true, :numericality => true
	validates :tabletsPerContainer,  :presence => true, :numericality => true

	set_primary_key :medId
	has_many :prescriptions, :foreign_key => 'medId'


	def  self.to_csv(options = {})
		CSV.generate(options) do |csv|
			csv << column_names
			all.each do |medication|
				csv << medication.attributes.values_at(*column_names)

			end
		end
	end

	def create_med_id(x)
		z = 0
		x.each_byte {|c| z += c}
		return z
		end
end

