require "rails_helper"

RSpec.describe "Entries", type: :feature do
  let(:user) { create :user }

  before do
    create :bucket, name: "CIC", account_type: :real, account: user.account
    create :bucket, name: "Savings", account_type: :spending, account: user.account

    sign_in_as user
  end

  scenario "a user creates a new entry" do
    visit "/entries/new"

    fill_in "Amount", with: "999.99"

    click_on "Create Entry"

    expect(page).to have_content "Credit account must be different to the debit account"

    select "CIC", from: "Debit account"
    select "Savings", from: "Credit account"

    click_on "Create Entry"

    expect(page).to have_content "999.99"
  end
end
