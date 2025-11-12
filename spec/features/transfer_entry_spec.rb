require "rails_helper"

RSpec.describe "Transfer Entries", type: :feature do
  let(:user) { create :user }
  let!(:checking_account) { create :bucket, name: "Checking Account", account_type: :real, account: user.account }
  let!(:savings_account) { create :bucket, name: "Savings Account", account_type: :real, account: user.account }
  let!(:credit_card) { create :bucket, name: "Credit Card", account_type: :real, account: user.account }

  before do
    sign_in_as user
  end

  scenario "a user successfully transfers funds between real accounts" do
    visit transfer_entries_path

    expect(page).to have_content "Transfer Between Accounts"

    fill_in "Transfer Amount", with: "500.00"
    select "Checking Account", from: "Transfer From (Account)"
    select "Savings Account", from: "Transfer To (Account)"

    click_on "Transfer"

    expect(page).to have_content "Transfer recorded successfully"
    expect(page).to have_content "500.0"
    expect(page).to have_content "Savings Account → Checking Account"
  end

  scenario "transfer form only shows real accounts for both debit and credit" do
    visit transfer_entries_path

    # Should have real accounts in both selectors
    expect(page).to have_select("Transfer From (Account)", with_options: [ "Checking Account" ])
    expect(page).to have_select("Transfer From (Account)", with_options: [ "Savings Account" ])
    expect(page).to have_select("Transfer From (Account)", with_options: [ "Credit Card" ])

    expect(page).to have_select("Transfer To (Account)", with_options: [ "Checking Account" ])
    expect(page).to have_select("Transfer To (Account)", with_options: [ "Savings Account" ])
    expect(page).to have_select("Transfer To (Account)", with_options: [ "Credit Card" ])
  end

  scenario "transfer form does not show virtual buckets" do
    # Create some virtual buckets
    create :bucket, name: "Salary", account_type: :income, account: user.account
    create :bucket, name: "Groceries", account_type: :spending, account: user.account

    visit transfer_entries_path

    # Should not have virtual buckets
    expect(page).not_to have_select("Transfer From (Account)", with_options: [ "Salary" ])
    expect(page).not_to have_select("Transfer From (Account)", with_options: [ "Groceries" ])
    expect(page).not_to have_select("Transfer To (Account)", with_options: [ "Salary" ])
    expect(page).not_to have_select("Transfer To (Account)", with_options: [ "Groceries" ])
  end

  scenario "validation errors re-render transfer form" do
    visit transfer_entries_path

    fill_in "Transfer Amount", with: ""
    select "Checking Account", from: "Transfer From (Account)"
    select "Savings Account", from: "Transfer To (Account)"

    click_on "Transfer"

    # Should still be on transfer form
    expect(page).to have_content "Transfer Between Accounts"
    expect(page).to have_button "Transfer"

    # Should show error
    expect(page).to have_content "prohibited this entry from being saved"
  end

  scenario "user can transfer funds to credit card" do
    visit transfer_entries_path

    fill_in "Transfer Amount", with: "1000.00"
    select "Checking Account", from: "Transfer From (Account)"
    select "Credit Card", from: "Transfer To (Account)"

    click_on "Transfer"

    expect(page).to have_content "Transfer recorded successfully"
    expect(page).to have_content "$1,000.00"
  end

  scenario "validation prevents same account for debit and credit" do
    visit transfer_entries_path

    fill_in "Transfer Amount", with: "100.00"
    select "Checking Account", from: "Transfer From (Account)"
    select "Checking Account", from: "Transfer To (Account)"

    click_on "Transfer"

    # Should show error
    expect(page).to have_content "Credit account must be different to the debit account"
  end

  scenario "form has default date set to today" do
    visit transfer_entries_path

    date_field = find_field("Date")
    expect(date_field.value).to eq(Date.today.to_s)
  end

  scenario "form has default currency set to EUR" do
    visit transfer_entries_path

    currency_field = find_field("Currency")
    expect(currency_field.value).to eq("EUR")
  end

  scenario "user cannot see another account's real accounts" do
    other_user = create :user
    other_checking = create :bucket, name: "Other Checking", account_type: :real, account: other_user.account
    other_savings = create :bucket, name: "Other Savings", account_type: :real, account: other_user.account

    visit transfer_entries_path

    expect(page).not_to have_select("Transfer From (Account)", with_options: [ "Other Checking" ])
    expect(page).not_to have_select("Transfer From (Account)", with_options: [ "Other Savings" ])
    expect(page).not_to have_select("Transfer To (Account)", with_options: [ "Other Checking" ])
    expect(page).not_to have_select("Transfer To (Account)", with_options: [ "Other Savings" ])
  end
end
