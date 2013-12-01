require 'spec_helper'

describe "Appuser pages" do
    subject { page }

    describe "Creates an appuser with write data" do

         before { visit createuser_path }

         let(:submit) {"Create my account"}

         describe "with valid information" do
            before do
            appuser = FactoryGirl.build(:appuser)
            fill_in "First Name",:with => appuser.firstName
            fill_in "appuser_lastName", :with => appuser.lastName
            fill_in "appuser_email", :with => appuser.email
            fill_in "appuser_password", :with => appuser.password
            fill_in "appuser_password_confirmation", :with => appuser.password_confirmation
            fill_in "appuser_userType", :with => appuser.userType
            fill_in "appuser_status", :with => appuser.status
        end
    end
    describe "edit" do
        appuser = FactoryGirl.build(:appuser)
        before do
            sign_in user
            vistit edit_appuser_path(appuser)
        end
    end
    end
end

# require 'spec_helper'

# describe "User pages" do

#   subject { page }

#   describe "create User" do

#     before { visit createuser_path }

#     let(:submit) { "Create my account" }

#     describe "with valid information" do
#       before do
#         fill_in "Name",         with: "Example User"
#         fill_in "Email",        with: "user@example.com"
#         fill_in "Password",     with: "foobar"
#         fill_in "Confirmation", with: "foobar"
#         fill_in "email",                      with: "michael@example.com"
#         fill_in "password"   ,                with: "foobar"
#         fill_in "password_confirmation" ,    with:  "foobar"
#         fill_in "userName"    ,             with: "ccorv001" 
#         fill_in " firstName "     ,            with: "carlos"
#         fill_in "lastName "   ,               with: "Corvaia"
#         fill_in "userType "   ,               with: "admin"
#         fill_in "status "    ,            with: "active"
#   end
#       end

#     describe "edit" do
#     let(:user) { FactoryGirl.create(:user) }
#     before do
#       sign_in user
#       visit edit_user_path(user)
#     end
      
#     end
#   end
# end