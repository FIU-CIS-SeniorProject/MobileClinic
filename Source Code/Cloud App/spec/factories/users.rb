 FactoryGirl.define do
  factory :user do |f|
    f.email    "michael@example.com"
    f.password "foobar"
    f.password_confirmation "foobar"
    f.userName "admin" 
    f.firstName "carlos"
    f.lastName "Corvaia"
    f.userType 0
    f.status "active"
  end
end
 FactoryGirl.define do
  factory :appuser do |f|
    f.userName "ccorv001" 
    f.firstName "carlos"
    f.lastName "Corvaia"
    f.email    "michael@example.com"
    f.password "foobar"
    f.userType 1
    f.status "active"
end
end