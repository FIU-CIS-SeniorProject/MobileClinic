class User < ActiveRecord::Base
  
  # before saving to the DB it will make userName and email to all lowercase Ensuring email uniquenesss
  before_save { |user| user.userName = userName.downcase}
  before_save { |user| user.email = email.downcase}
  before_save { |user| user.answer = answer.downcase}
  before_save :create_remember_token

  attr_accessible :email, :firstName, :lastName, :password, :password_confirmation, :status, :userType, 
  :userName, :avatar, :delete_avatar, :userid, :charityid, :question, :answer,:created_at,:updated_at
  has_secure_password
  
  before_validation :clear_avatar
  
  validates :password, presence: true, length:  { minimum: 6 }, :on => :create
  validates :password_confirmation, presence: true, length: { minimum: 6 } , :on => :create

  validates :userName, presence: true , length: {maximum: 50 , minimum: 5} , uniqueness: true

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true , format: { with: VALID_EMAIL_REGEX } , uniqueness: true

  validates :lastName, presence: true    
  validates :firstName, presence: true
  validates :status, presence: true
  validates :userType, presence: true
  validates :charityid, presence: true
  validates :question, presence: true
  validates :answer, presence: true
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment :avatar,
  :content_type => { :content_type => [/^image\/(?:jpeg|gif|png)$/, nil] },
  :size => { :in => 0..2000.kilobytes }

  self.primary_key = "userid"
  attr_accessor :updating_password
  
    def delete_avatar=(value)
      @delete_avatar = !value.to_i.zero?
    end
    
    def delete_avatar
      !!@delete_avatar
    end
    alias_method :delete_avatar?, :delete_avatar
    
    # Later in the model
    def clear_avatar
      self.avatar = nil if delete_avatar? && !avatar.dirty?
    end

    private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end

    def should_validate_password?
      updating_password       
    end
  end

