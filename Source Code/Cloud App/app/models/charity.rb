class Charity < ActiveRecord::Base
  attr_accessible :charityid, :name, :status,:name_lowercase,:created_at,:updated_at
  
  before_validation { |user| user.name_lowercase = name.downcase}
  
  validates :name_lowercase, :presence => true, uniqueness: {:message => "already exist, check lower and upper case letters."}
	validates :name, :presence => true
	validates :status, :presence => true	
	
	self.primary_key = "charityid"
	has_many :users, :foreign_key => 'charityid'
	has_many :appusers, :foreign_key => 'charityid'
end
