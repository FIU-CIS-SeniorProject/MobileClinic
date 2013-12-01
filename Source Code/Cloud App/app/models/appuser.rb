class Appuser < ActiveRecord::Base
  attr_accessible :status, :userType, :email, :appuserid, :lastName, :firstName, :password, :userName, 
                  :secondaryTypes, :avatar, :delete_avatar,:charityid,:created_at,:updated_at

  # before saving to the DB it will make userName and email to all lowercase Ensuring email uniquenesss
  before_save { |appuser| appuser.userName = userName.downcase}
  before_save { |appuser| appuser.email = email.downcase}
  before_validation :clear_photo
  attr_accessible :email, :firstName, :lastName, :appuserid,:password, :password_confirmation, :status, :userType, 
                  :userName,:charityid,:created_at,:updated_at

  validates :password, length:  { minimum: 6 }, :on => :create

  validates :userName, presence: true , length: {maximum: 50 , minimum: 5} , uniqueness: true

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true , format: { with: VALID_EMAIL_REGEX } , uniqueness: true 
  validates :lastName, presence: true    
  validates :firstName, presence: true
  validates :status, presence: true
  validates :userType, presence: true
  validates :charityid, presence: true
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment :avatar,
  :content_type => { :content_type => [/^image\/(?:jpeg|gif|png)$/, nil] },
  :size => { :in => 0..2000.kilobytes }

  self.primary_key = 'appuserid'
  has_many :visits, :foreign_key => 'doctorId'

 def delete_avatar=(value)
    @delete_avatar = !value.to_i.zero?
  end
  
  def delete_avatar
    !!@delete_avatar
  end
  alias_method :delete_avatar?, :delete_avatar

  # Later in the model
def clear_photo
  self.avatar = nil if delete_avatar? && !avatar.dirty?
end

end