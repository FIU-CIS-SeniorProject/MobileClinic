class Charity < ActiveRecord::Base
  attr_accessible :charityid, :name, :status,:created_at,:updated_at
  
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false, conditions: -> { where.not(status: 0) }
	validates :status, :presence => true	
	
	self.primary_key = "charityid"
	has_many :users, :foreign_key => 'charityid'
	has_many :appusers, :foreign_key => 'charityid'
end
