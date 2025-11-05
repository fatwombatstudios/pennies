def authenticate(user)
end

def sign_in_as(user)
  visit sign_in_path

  fill_in "Email", with: user.email
  fill_in "Password", with: user.password

  click_button "Sign In"
end
