class Patient < ActiveRecord::Base
  
  attr_accessible :age, :firstName, :familyName, :sex, :villageName, :picture, :patientId

  validates :age, presence: true, :numericality => { :only_integer => true }
  # validates :createdAt, presence: true 
  validates :firstName, presence: true, :format => { :with => /\A[a-zA-Z]+\z/ }
  validates :familyName, presence: true, :format => { :with => /\A[a-zA-Z]+\z/ }
  validates :sex, presence: true, :numericality => { :only_integer => true }
  validates :villageName, presence: true, :format => { :with => /\A[a-zA-Z]+\z/ }
  validates :patientId, presence: true, :uniqueness => true

  has_attached_file :picture, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :url => "images/:style/missing.png"

  set_primary_key :patientId
  has_many :visits, dependent: :destroy, :foreign_key => 'patientId'

  def visitFeed
    Visits.from_patients_my_visits(self)
  end
  def name
    [firstName, familyName].join " "
  end
end