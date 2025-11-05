require "rails_helper"

RSpec.describe "Sessions", type: :feature do
  before do
    @user = create :user, email: "user@example.com", password: "password123"
  end

  scenario "a user signs in successfully" do
    visit "/sign-in"

    fill_in "Email", with: @user.email
    fill_in "Password", with: @user.password

    click_on "Sign In"

    expect(page).to have_content "Signed in successfully"
  end

  scenario "a user fails to sign in with wrong password" do
    visit "/sign-in"

    fill_in "Email", with: @user.email
    fill_in "Password", with: "wrongpassword"

    click_on "Sign In"

    expect(page).to have_content "Invalid email or password"
  end

  scenario "a user fails to sign in with non-existent email" do
    visit "/sign-in"

    fill_in "Email", with: "nonexistent@example.com"
    fill_in "Password", with: @user.password

    click_on "Sign In"

    expect(page).to have_content "Invalid email or password"
  end

  scenario "a user signs out" do
    visit "/sign-in"

    fill_in "Email", with: @user.email
    fill_in "Password", with: @user.password

    click_on "Sign In"

    visit "/sign-out"

    expect(page).to have_content "Signed out successfully"
  end
end
