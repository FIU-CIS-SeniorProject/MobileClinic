 require 'faker'
 
 FactoryGirl.define do
  factory :patient do |f|
    f.firstName {Faker::Name.first_name}
    f.familyName {Faker::Name.last_name}
    f.sex 0 
    f.villageName {Faker::Address.city}
    f.age 25
    f.patientId "foobar"
  end
end