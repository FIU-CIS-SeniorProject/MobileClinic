include ApplicationHelper


def valid_signin(user)
    visit home_path
  fill_in "session_userName",    with: user.userName
  fill_in "session_password", with: user.password
  click_button "Sign in"
   # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.remember_token
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-error', text: message)
  end
end