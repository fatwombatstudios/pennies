require "rails_helper"

RSpec.describe "Accounts", type: :feature do
  scenario "browsing all accounts" do
    create :account, name: "Savings"

    visit "/accounts"

    expect(page).to have_content "Accounts"
    expect(page).to have_content "Savings"
  end

  scenario "a user views an accounts" do
    account = create :account, name: "Savings"

    visit "/accounts/#{account.id}"

    expect(page).to have_content "Savings Account"
  end

  scenario "a user creates a new virtual account" do
    visit "/accounts/new"

    fill_in "Name", with: "Groceries"
    fill_in "Description", with: "For food and drink"

    click_button "Create Account"

    expect(page).to have_content "Accounts"
    expect(page).to have_content "Groceries"
    expect(page).to have_content "For food and drink"
    expect(page).to have_content "Virtual"
  end
end
