require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "create User" do

    before { visit createuser_path }

    let(:submit) { "Create my account" }

    describe "with valid information" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
        fill_in "email",                      with: "michael@example.com"
        fill_in "password"   ,                with: "foobar"
        fill_in "password_confirmation" ,    with:  "foobar"
        fill_in "userName"    ,             with: "ccorv001" 
        fill_in " firstName "     ,            with: "carlos"
        fill_in "lastName "   ,               with: "Corvaia"
        fill_in "userType "   ,               with: "admin"
        fill_in "status "    ,            with: "active"
  end
      end

    describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end
      
    end
  end
end