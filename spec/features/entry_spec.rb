require "rails_helper"

RSpec.describe "Entries", type: :feature do
  before do
    create :bucket, name: "CIC", account_type: :real
    create :bucket, name: "Savings", account_type: :virtual
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
