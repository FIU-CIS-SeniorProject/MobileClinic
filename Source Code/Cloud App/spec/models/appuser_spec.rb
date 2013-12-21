require 'spec_helper'

describe Appuser do
 
# == Schema Information
#
# Table name: appuser
#
# string   "userName"
# string   "password"
# string   "firstName"
# string   "lastName"
# string   "email"
# integer  "userType"
# integer  "status"
# integer  "secondaryTypes"
# datetime "created_at",     :null => false
# datetime "updated_at",     :null => false
#

# require 'spec_helper'

describe User do
  before {@appuser = FactoryGirl.build(:appuser)}

  subject { @appuser }

  # test for the existence of userName, password, firstName, lastName, email, userType Attributes
  it { should respond_to(:userName) }
  it { should respond_to(:password) }
  it { should respond_to(:firstName) }
  it { should respond_to(:lastName) }
  it { should respond_to(:email) }
  it { should respond_to(:userType) }
  it { should respond_to(:status)}
  it { should respond_to(:appuserid)}

  ####################
  # VALIDATION TESTS #
  ####################

  # Validation test for userName
describe "when userName is not present" do
  before { @appuser.userName = " " }
  it { should_not be_valid }
end

describe "when userName is too long" do
    before { @appuser.userName = "a" * 51 }
    it { should_not be_valid }
  end

describe "when userName is too short" do
    before { @appuser.userName = "a"}
    it { should_not be_valid }
  end

# describe "when userName is already taken" do
#     before do
#       user_with_same_userName = @appuser.dup
#       user_with_same_userName.save
#     end
#     it { should_not be_valid }
#   end

 # Validation test for password
describe "when password is not present" do
  before { @appuser.password =  " " }
  it { should_not be_valid }
end

describe "when password is nil" do
  before { @appuser.password = nil }
  it { should_not be_valid }
end

describe "with a password that's too short" do
  before { @appuser.password = "a" * 5 }
  it { should be_invalid }
end

# Email Validation
describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @appuser.email = invalid_address
        @appuser.should_not be_valid
      end      
    end
  end

#  describe "when email format is valid" do
 #   it "should be valid" do
  #    addresses = %w[user@foo.com A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
   #  addresses.each do |valid_address|
    #   @appuser.email = valid_address.downcase
    #    @appuser.should be_valid
   #   end      
  #  end
 # end

# Validation test for firstName
describe "when firstName is not present" do
  before { @appuser.firstName = " " }
  it { should_not be_valid }
end

# Validation test for lastName
describe "when lastName is not present" do
  before { @appuser.lastName = " " }
  it { should_not be_valid }
end

# Validation test for userType
describe "when userType is not present" do
  before { @appuser.userType = " " }
  it { should_not be_valid }
end

# Validation test for status
  describe "when status is not present" do
  before { @appuser.status = " " }
  it { should_not be_valid }
end
end
end
