class Serial < ActiveRecord::Base
  attr_accessible :serialId, :serialnum, :charityid,:charityName,:status,:created_at,:updated_at
  
  before_save { |serial| serial.charityName = Charity.select("name").where("charityid = ?", serial.charityid)[0].name}
  
  
  validates_presence_of :serialnum
  validates_presence_of :charityid
  validates_uniqueness_of :serialnum, :case_sensitive => false, conditions: -> { where.not(status: 0) }
  validates :status, :presence => true
  
  self.primary_key = "serialId"
end
