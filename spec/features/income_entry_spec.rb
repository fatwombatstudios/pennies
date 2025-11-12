require "rails_helper"

RSpec.describe "Income Entries", type: :feature do
  let(:user) { create :user }
  let!(:bank_account) { create :bucket, name: "Bank Account", account_type: :real, account: user.account }
  let!(:salary_bucket) { create :bucket, name: "Salary", account_type: :income, account: user.account }
  let!(:freelance_bucket) { create :bucket, name: "Freelance", account_type: :income, account: user.account }

  before do
    sign_in_as user
  end

  scenario "a user successfully records income" do
    visit income_entries_path

    expect(page).to have_content "Record Income"

    fill_in "Income Amount", with: "2500.00"
    select "Bank Account", from: "Deposit To (Bank Account)"
    select "Salary", from: "Income Category"

    click_on "Record Income"

    expect(page).to have_content "Income recorded successfully"
    expect(page).to have_content "$2,500.00"
    expect(page).to have_content "Salary to Bank Account"
  end

  scenario "income form only shows real accounts for debit" do
    visit income_entries_path

    expect(page).to have_select("Deposit To (Bank Account)", with_options: [ "Bank Account" ])

    expect(page).not_to have_select("Deposit To (Bank Account)", with_options: [ "Salary" ])
    expect(page).not_to have_select("Deposit To (Bank Account)", with_options: [ "Freelance" ])
  end

  scenario "income form only shows income buckets for credit" do
    visit income_entries_path

    expect(page).to have_select("Income Category", with_options: [ "Salary" ])
    expect(page).to have_select("Income Category", with_options: [ "Freelance" ])

    expect(page).not_to have_select("Income Category", with_options: [ "Bank Account" ])
  end

  scenario "validation errors re-render income form" do
    visit income_entries_path

    fill_in "Income Amount", with: ""
    select "Bank Account", from: "Deposit To (Bank Account)"
    select "Salary", from: "Income Category"

    click_on "Record Income"

    expect(page).to have_content "Record Income"
    expect(page).to have_button "Record Income"

    expect(page).to have_content "prohibited this entry from being saved"
  end

  scenario "user cannot see another account's buckets" do
    other_user = create :user
    other_bank = create :bucket, name: "Other Bank", account_type: :real, account: other_user.account
    other_income = create :bucket, name: "Other Income", account_type: :income, account: other_user.account

    visit income_entries_path

    expect(page).not_to have_select("Deposit To (Bank Account)", with_options: [ "Other Bank" ])
    expect(page).not_to have_select("Income Category", with_options: [ "Other Income" ])
  end
end
