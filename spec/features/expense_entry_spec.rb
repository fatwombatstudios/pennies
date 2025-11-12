require "rails_helper"

RSpec.describe "Expense Entries", type: :feature do
  let(:user) { create :user }
  let!(:bank_account) { create :bucket, name: "Bank Account", account_type: :real, account: user.account }
  let!(:credit_card) { create :bucket, name: "Credit Card", account_type: :real, account: user.account }
  let!(:groceries_bucket) { create :bucket, name: "Groceries", account_type: :spending, account: user.account }
  let!(:savings_bucket) { create :bucket, name: "Emergency Fund", account_type: :spending, account: user.account }

  before do
    sign_in_as user
  end

  scenario "a user successfully records an expense" do
    visit expense_entries_path

    expect(page).to have_content "Record Expense"

    fill_in "Expense Amount", with: "125.50"
    select "Groceries", from: "Spending Category"
    select "Bank Account", from: "Pay From (Bank Account)"

    click_on "Record Expense"

    expect(page).to have_content "Expense recorded successfully"
    expect(page).to have_content "125.50"
    expect(page).to have_content "Groceries → Bank Account"
  end

  scenario "expense form only shows spending/savings buckets for debit" do
    visit expense_entries_path

    expect(page).to have_select("Spending Category", with_options: [ "Groceries" ])
    expect(page).to have_select("Spending Category", with_options: [ "Emergency Fund" ])

    expect(page).not_to have_select("Spending Category", with_options: [ "Bank Account" ])
    expect(page).not_to have_select("Spending Category", with_options: [ "Credit Card" ])
  end

  scenario "expense form only shows real accounts for credit" do
    visit expense_entries_path

    expect(page).to have_select("Pay From (Bank Account)", with_options: [ "Bank Account" ])
    expect(page).to have_select("Pay From (Bank Account)", with_options: [ "Credit Card" ])

    expect(page).not_to have_select("Pay From (Bank Account)", with_options: [ "Groceries" ])
    expect(page).not_to have_select("Pay From (Bank Account)", with_options: [ "Emergency Fund" ])
  end

  scenario "validation errors re-render expense form" do
    visit expense_entries_path

    fill_in "Expense Amount", with: ""
    select "Groceries", from: "Spending Category"
    select "Bank Account", from: "Pay From (Bank Account)"

    click_on "Record Expense"

    expect(page).to have_content "Record Expense"
    expect(page).to have_button "Record Expense"

    expect(page).to have_content "prohibited this entry from being saved"
  end

  scenario "user can pay from savings bucket" do
    visit expense_entries_path

    fill_in "Expense Amount", with: "500.00"
    select "Emergency Fund", from: "Spending Category"
    select "Bank Account", from: "Pay From (Bank Account)"

    click_on "Record Expense"

    expect(page).to have_content "Expense recorded successfully"
    expect(page).to have_content "500.00"
  end

  scenario "user cannot see another account's buckets" do
    other_user = create :user
    other_bank = create :bucket, name: "Other Bank", account_type: :real, account: other_user.account
    other_spending = create :bucket, name: "Other Groceries", account_type: :spending, account: other_user.account

    visit expense_entries_path

    expect(page).not_to have_select("Spending Category", with_options: [ "Other Groceries" ])
    expect(page).not_to have_select("Pay From (Bank Account)", with_options: [ "Other Bank" ])
  end
end
