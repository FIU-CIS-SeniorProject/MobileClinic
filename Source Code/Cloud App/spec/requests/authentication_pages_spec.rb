# require 'spec_helper'

# describe "Authentication" do

#   subject { page }

#   describe "signin page" do
#     before { visit signin_path }

#     describe "with invalid information" do
#       before { click_button "Sign in" }

#       end
#       describe "with valid information" do
#         let(:user) { FactoryGirl.create(:user) }
#         before do
#             fill_in "userName",    with: user.userName.upcase
#             fill_in "Password", with: user.password
#             click_button "Sign in"
#       end
#     end
#   end

#  describe "authorization" do

#     describe "for non-signed-in users" do
#       let(:user) { FactoryGirl.create(:user) }

#       describe "in the Users controller" do

#         describe "visiting the edit page" do
#           before { visit edit_user_path(user) }
#           it { should have_selector('title', text: 'Sign in') }
#         end

#         describe "submitting to the update action" do
#           before { put user_path(user) }
#           specify { response.should redirect_to(signin_path) }
#         end
#       end
#     end


#  end
# end
