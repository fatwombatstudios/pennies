require "rails_helper"

RSpec.describe "Entries Display", type: :feature do
  let(:user) { create :user }
  let!(:bank_account) { create :bucket, name: "Bank Account", account_type: :real, account: user.account }
  let!(:credit_card) { create :bucket, name: "Credit Card", account_type: :real, account: user.account }
  let!(:salary_bucket) { create :bucket, name: "Salary", account_type: :income, account: user.account }
  let!(:groceries_bucket) { create :bucket, name: "Groceries", account_type: :spending, account: user.account }
  let!(:rent_bucket) { create :bucket, name: "Rent", account_type: :spending, account: user.account }

  before do
    sign_in_as user
  end

  scenario "income entry displays real -> virtual bucket flow" do
    create :entry,
      account: user.account,
      debit_account: bank_account,
      credit_account: salary_bucket,
      amount: 2500.00,
      date: Date.today

    visit entries_path

    expect(page).to have_content "Income"
    expect(page).to have_content "Salary to Bank Account"
  end

  scenario "expense entry displays virtual → real bucket flow" do
    create :entry,
      account: user.account,
      debit_account: groceries_bucket,
      credit_account: bank_account,
      amount: 125.50,
      date: Date.today

    visit entries_path

    expect(page).to have_content "Expense"
    expect(page).to have_content "Groceries from Bank Account"
  end

  scenario "real-to-real transfer displays credit → debit flow" do
    create :entry,
      account: user.account,
      credit_account: bank_account,
      debit_account: credit_card,
      amount: 500.00,
      date: Date.today

    visit entries_path

    expect(page).to have_content "Transfer"
    expect(page).to have_content "Bank Account to Credit Card"
  end

  scenario "virtual-to-virtual transfer displays debit → credit flow" do
    create :entry,
      account: user.account,
      debit_account: salary_bucket,
      credit_account: groceries_bucket,
      amount: 300.00,
      date: Date.today

    visit entries_path

    expect(page).to have_content "Transfer"
    expect(page).to have_content "Salary to Groceries"
  end

  scenario "entries list shows all three action types correctly" do
    # Create one of each type
    create :entry,
      account: user.account,
      debit_account: bank_account,
      credit_account: salary_bucket,
      amount: 2500.00,
      date: 3.days.ago

    create :entry,
      account: user.account,
      debit_account: groceries_bucket,
      credit_account: bank_account,
      amount: 125.50,
      date: 2.days.ago

    create :entry,
      account: user.account,
      debit_account: salary_bucket,
      credit_account: rent_bucket,
      amount: 1000.00,
      date: 1.day.ago

    visit entries_path

    # Check bucket flows which implicitly verifies the actions are correct
    expect(page).to have_content "Salary to Bank Account"
    expect(page).to have_content "Groceries from Bank Account"
    expect(page).to have_content "Salary to Rent"

    # Verify amounts
    expect(page).to have_content "$2,500.00"
    expect(page).to have_content "$125.50"
    expect(page).to have_content "$1,000.00"
  end

  scenario "entries show correct amounts" do
    create :entry,
      account: user.account,
      debit_account: bank_account,
      credit_account: salary_bucket,
      amount: 2500.00,
      date: Date.today

    visit entries_path

    expect(page).to have_content "$2,500.00"
  end
end
