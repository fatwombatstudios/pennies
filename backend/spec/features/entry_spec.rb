require "rails_helper"

RSpec.describe "Entries", type: :feature do
  let(:user) { create :user }

  before do
    create :bucket, name: "CIC", account_type: :real, account: user.account
    create :bucket, name: "Cash", account_type: :real, account: user.account
    create :bucket, name: "Savings", account_type: :spending, account: user.account
    create :bucket, name: "Emergency", account_type: :spending, account: user.account
    create :bucket, name: "Salary", account_type: :income, account: user.account

    sign_in_as user
  end

  scenario "a user creates an expense entry", js: true do
    visit "/entries/new"

    fill_in "Amount", with: "999.99"

    select "Expense", from: "Transaction Type"

    # Wait for JavaScript to show the dynamic fields
    expect(page).to have_select("Bucket")

    click_on "Create Entry"

    expect(page).to have_content "Credit account must be different to the debit account"

    select "Expense", from: "Transaction Type"
    select "Savings", from: "Bucket"
    select "CIC", from: "From"
    fill_in "Description", with: "Foo"

    click_on "Create Entry"

    expect(page).to have_content "999.99"
    expect(page).to have_content "Foo"
  end

  scenario "a user creates an income entry", js: true do
    visit "/entries/new"

    fill_in "Amount", with: "1500.00"

    select "Income", from: "Transaction Type"

    # Wait for JavaScript to show the dynamic fields
    expect(page).to have_select("Income")

    select "Salary", from: "Income"
    select "CIC", from: "Into"

    click_on "Create Entry"

    expect(page).to have_content "Income recorded successfully"
    expect(page).to have_content "$1,500.00"
  end

  scenario "a user creates a transfer between real accounts", js: true do
    visit "/entries/new"

    fill_in "Amount", with: "250.00"

    select "Transfer", from: "Transaction Type"

    # Wait for JavaScript to show the dynamic fields
    expect(page).to have_select("From")

    select "CIC", from: "From"

    # After selecting a real account in "From", "To" should only show real accounts
    expect(page).to have_select("To", with_options: [ "Cash" ])
    expect(page).not_to have_select("To", with_options: [ "Savings" ])

    select "Cash", from: "To"

    click_on "Create Entry"

    expect(page).to have_content "Transfer recorded successfully"
    expect(page).to have_content "250.00"
  end

  scenario "a user creates a transfer between virtual buckets", js: true do
    visit "/entries/new"

    fill_in "Amount", with: "100.00"

    select "Transfer", from: "Transaction Type"

    # Wait for JavaScript to show the dynamic fields
    expect(page).to have_select("From")

    select "Savings", from: "From"

    # After selecting a virtual bucket in "From", "To" should only show virtual buckets
    expect(page).to have_select("To", with_options: [ "Emergency" ])
    expect(page).not_to have_select("To", with_options: [ "CIC" ])

    select "Emergency", from: "To"

    click_on "Create Entry"

    expect(page).to have_content "Transfer recorded successfully"
    expect(page).to have_content "100.00"
  end
end
