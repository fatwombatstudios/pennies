require "rails_helper"

RSpec.describe "Allocation Entries", type: :feature do
  let(:user) { create :user }
  let!(:bank_account) { create :bucket, name: "Bank Account", account_type: :real, account: user.account }
  let!(:salary_bucket) { create :bucket, name: "Salary", account_type: :income, account: user.account }
  let!(:groceries_bucket) { create :bucket, name: "Groceries", account_type: :spending, account: user.account }
  let!(:rent_bucket) { create :bucket, name: "Rent", account_type: :spending, account: user.account }
  let!(:savings_bucket) { create :bucket, name: "Emergency Fund", account_type: :savings, account: user.account }

  before do
    sign_in_as user
  end

  scenario "a user successfully allocates funds between buckets" do
    visit allocation_entries_path

    expect(page).to have_content "Allocate Between Buckets"

    fill_in "Allocation Amount", with: "300.00"
    select "Salary", from: "Transfer From"
    select "Groceries", from: "Transfer To"

    click_on "Allocate Funds"

    expect(page).to have_content "Allocation completed successfully"
    expect(page).to have_content "300.00"
  end

  scenario "allocation form only shows virtual buckets" do
    visit allocation_entries_path

    expect(page).to have_select("Transfer From", with_options: [ "Salary" ])
    expect(page).to have_select("Transfer From", with_options: [ "Groceries" ])
    expect(page).to have_select("Transfer From", with_options: [ "Rent" ])
    expect(page).to have_select("Transfer From", with_options: [ "Emergency Fund" ])

    expect(page).to have_select("Transfer To", with_options: [ "Salary" ])
    expect(page).to have_select("Transfer To", with_options: [ "Groceries" ])
    expect(page).to have_select("Transfer To", with_options: [ "Rent" ])
    expect(page).to have_select("Transfer To", with_options: [ "Emergency Fund" ])

    expect(page).not_to have_select("Transfer From", with_options: [ "Bank Account" ])
    expect(page).not_to have_select("Transfer To", with_options: [ "Bank Account" ])
  end

  scenario "validation errors re-render allocation form" do
    visit allocation_entries_path

    fill_in "Allocation Amount", with: ""
    select "Salary", from: "Transfer From"
    select "Groceries", from: "Transfer To"

    click_on "Allocate Funds"

    expect(page).to have_content "Allocate Between Buckets"
    expect(page).to have_button "Allocate Funds"

    expect(page).to have_content "prohibited this entry from being saved"
  end

  scenario "user can allocate from spending to savings" do
    visit allocation_entries_path

    fill_in "Allocation Amount", with: "200.00"
    select "Groceries", from: "Transfer From"
    select "Emergency Fund", from: "Transfer To"

    click_on "Allocate Funds"

    expect(page).to have_content "Allocation completed successfully"
    expect(page).to have_content "200.00"
  end

  scenario "user can allocate from income to spending" do
    visit allocation_entries_path

    fill_in "Allocation Amount", with: "150.00"
    select "Salary", from: "Transfer From"
    select "Rent", from: "Transfer To"

    click_on "Allocate Funds"

    expect(page).to have_content "Allocation completed successfully"
    expect(page).to have_content "150.00"
  end

  scenario "validation prevents same bucket for debit and credit" do
    visit allocation_entries_path

    fill_in "Allocation Amount", with: "100.00"
    select "Groceries", from: "Transfer From"
    select "Groceries", from: "Transfer To"

    click_on "Allocate Funds"

    expect(page).to have_content "Credit account must be different to the debit account"
  end

  scenario "form has default date set to today" do
    visit allocation_entries_path

    date_field = find_field("Date")
    expect(date_field.value).to eq(Date.today.to_s)
  end

  scenario "form has default currency set to EUR" do
    visit allocation_entries_path

    currency_field = find_field("Currency")
    expect(currency_field.value).to eq("EUR")
  end

  scenario "user cannot see another account's buckets" do
    other_user = create :user
    other_income = create :bucket, name: "Other Salary", account_type: :income, account: other_user.account
    other_spending = create :bucket, name: "Other Groceries", account_type: :spending, account: other_user.account

    visit allocation_entries_path

    expect(page).not_to have_select("Transfer From", with_options: [ "Other Salary" ])
    expect(page).not_to have_select("Transfer From", with_options: [ "Other Groceries" ])
    expect(page).not_to have_select("Transfer To", with_options: [ "Other Salary" ])
    expect(page).not_to have_select("Transfer To", with_options: [ "Other Groceries" ])
  end
end
