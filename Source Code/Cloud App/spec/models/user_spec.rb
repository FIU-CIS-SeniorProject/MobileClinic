# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  userName        :string(255)
#  password_digest :string(255)
#  firstName       :string(255)
#  lastName        :string(255)
#  email           :string(255)
#  userType        :string(255)
#  status          :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'spec_helper'

describe User do
  before {@user = User.new(userName: "epere250", firstName: "Ernesto",
                            lastName: "Perez", password: "foobar", password_confirmation: "foobar",
                            email: "epere250@fiu.edu", userType: 0, status: 1, charityid: "1",
                            question: "1", answer: "elpidio valdes")}

  subject { @user }

  # test for the existence of userName, password_digest, firstName, lastName, email, userType Attributes
  it { should respond_to(:userName) }
  it { should respond_to(:userid) }
  #it { should respond_to(:password_digest) }
  it { should respond_to(:firstName) }
  it { should respond_to(:lastName) }
  it { should respond_to(:email) }
  it { should respond_to(:userType) }
  it { should respond_to(:charityid) }
  it { should respond_to(:question) }
  it { should respond_to(:answer) }

  # test for sessions rememeber acction
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }  

  # virtual attributes
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }

  ####################
  # VALIDATION TESTS #
  ####################

  # A test for a valid (nonblank) remember token. 
  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end
  # Validation test for usersLogin
describe "when userName is not present" do
  before { @user.userName = " " }
  it { should_not be_valid }
end

describe "when userName is too long" do
    before { @user.userName = "a" * 51 }
    it { should_not be_valid }
  end

describe "when userName is too short" do
    before { @user.userName = "a"}
    it { should_not be_valid }
  end

# describe "when userName address is already taken" do
#     before do
#       user_with_same_userName = @user.dup
#       user_with_same_userName.save
#     end
#     it { should be_valid }
#   end

 # Validation test for password_digest
describe "when password is not present" do
  before { @user.password = @user.password_confirmation = " " }
  it { should_not be_valid }
end

describe "when password doesn't match confirmation" do
  before { @user.password_confirmation = "mismatch" }
  it { should_not be_valid }
end

describe "when password confirmation is nil" do
  before { @user.password_confirmation = nil }
  it { should_not be_valid }
end

describe "with a password that's too short" do
  before { @user.password = @user.password_confirmation = "a" * 5 }
  it { should be_invalid }
end

# User authentication tests
describe "return value of authenticate method" do
  before { @user.save }
  let(:found_user) { User.find_by_email(@user.email)}

  describe "with valid password" do
    it {found_user.authenticate(@user.password.should be_true)}
  end

  describe "with invalid password" do
    let(:user_for_invalid_password) {found_user.authenticate("invalid") }

    it { should_not == user_for_invalid_password }
    specify { user_for_invalid_password.should be_false }
  end
end

# Email Validation
describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        @user.should_not be_valid
      end      
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address.downcase
        @user.should be_valid
      end      
    end
  end

# describe "when email address is already taken" do
#     before do
#       user_with_same_email = @user.dup
#       user_with_same_email.save
#     end

#     it { should be_valid }
#   end


# Validation test for firstName
describe "when firstName is not present" do
  before { @user.firstName = " " }
  it { should_not be_valid }
end

# Validation test for lastName
describe "when lastName is not present" do
  before { @user.lastName = " " }
  it { should_not be_valid }
end

# Validation test for userType
describe "when userType is not present" do
  before { @user.userType = " " }
  it { should_not be_valid }
end

# Validation test for status
  describe "when status is not present" do
  before { @user.status = " " }
  it { should_not be_valid }
end

end
