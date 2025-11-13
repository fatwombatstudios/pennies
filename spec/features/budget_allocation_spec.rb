require "rails_helper"

RSpec.describe "Budget Allocations", type: :feature do
  let(:user) { create :user }
  let!(:income_bucket) { create :bucket, name: "Salary", account_type: :income, account: user.account }
  let!(:groceries_bucket) { create :bucket, name: "Groceries", account_type: :spending, account: user.account }
  let!(:mortgage_bucket) { create :bucket, name: "Mortgage", account_type: :spending, account: user.account }
  let!(:savings_bucket) { create :bucket, name: "Savings", account_type: :spending, account: user.account }
  let!(:real_account) { create :bucket, name: "Bank", account_type: :real, account: user.account }

  before do
    # Create income entry to give the income bucket a balance
    create :entry,
           account: user.account,
           debit_account: real_account,
           credit_account: income_bucket,
           amount: 1000.00,
           date: Date.today

    sign_in_as user
  end

  scenario "a user can view the budget allocation page" do
    visit "/budget"

    expect(page).to have_content "Budget Allocation"
    expect(page).to have_content "Select Income Bucket"
    expect(page).to have_content "Groceries"
    expect(page).to have_content "Mortgage"
    expect(page).to have_content "Savings"
  end

  scenario "a user allocates income to multiple spending buckets", js: true do
    visit "/budget"

    # Select income bucket
    select "Salary ($1,000.00)", from: "budget_allocation_income_bucket_id"

    # Wait for allocation form to appear
    expect(page).to have_content "Available to Allocate"

    # Fill in allocation amounts
    fill_in "budget_allocation[allocations][#{groceries_bucket.id}]", with: "300.00"
    fill_in "budget_allocation[allocations][#{mortgage_bucket.id}]", with: "500.00"
    fill_in "budget_allocation[allocations][#{savings_bucket.id}]", with: "200.00"

    # Submit the form
    click_button "Assign"

    # Verify success
    expect(page).to have_content "Successfully allocated 3 budget(s)"

    # Verify entries were created
    expect(user.account.entries.count).to eq 4 # 1 initial + 3 new allocations

    # Verify income bucket balance decreased
    income_bucket.reload
    expect(income_bucket.balance).to eq 0.00

    # Verify spending buckets received allocations
    groceries_bucket.reload
    mortgage_bucket.reload
    savings_bucket.reload

    expect(groceries_bucket.balance).to eq 300.00
    expect(mortgage_bucket.balance).to eq 500.00
    expect(savings_bucket.balance).to eq 200.00
  end

  scenario "a user cannot allocate more than available income", js: true do
    visit "/budget"

    # Select income bucket
    select "Salary ($1,000.00)", from: "budget_allocation_income_bucket_id"

    # Wait for allocation form to appear
    expect(page).to have_content "Available to Allocate"

    # Try to allocate more than available
    fill_in "budget_allocation[allocations][#{groceries_bucket.id}]", with: "600.00"
    fill_in "budget_allocation[allocations][#{mortgage_bucket.id}]", with: "600.00"

    # Submit the form
    click_button "Assign"

    # Verify error
    expect(page).to have_content "Insufficient balance in income bucket"

    # Verify no entries were created
    expect(user.account.entries.count).to eq 1 # Only the initial entry

    # Verify bucket balances unchanged
    income_bucket.reload
    groceries_bucket.reload
    mortgage_bucket.reload

    expect(income_bucket.balance).to eq 1000.00
    expect(groceries_bucket.balance).to eq 0.00
    expect(mortgage_bucket.balance).to eq 0.00
  end

  scenario "the correct number of transaction entries are created" do
    visit "/budget"

    # Select income bucket
    select "Salary ($1,000.00)", from: "budget_allocation_income_bucket_id"

    # Allocate to 2 buckets only (skip mortgage)
    fill_in "budget_allocation[allocations][#{groceries_bucket.id}]", with: "400.00"
    fill_in "budget_allocation[allocations][#{savings_bucket.id}]", with: "600.00"

    # Submit the form
    click_button "Assign"

    # Verify exactly 2 new entries were created (plus 1 initial)
    expect(user.account.entries.count).to eq 3

    # Verify the entries have correct structure
    new_entries = user.account.entries.where.not(id: Entry.first.id)
    expect(new_entries.count).to eq 2

    new_entries.each do |entry|
      expect(entry.debit_account_id).to eq income_bucket.id
      expect(entry.credit_account_id).to be_in([ groceries_bucket.id, savings_bucket.id ])
      expect(entry.amount).to be > 0
      expect(entry.action).to eq :transfer
    end
  end

  scenario "buckets can't go below zero" do
    # Set up a scenario where income bucket only has $100
    income_bucket.debits.destroy_all
    income_bucket.credits.destroy_all
    create :entry,
           account: user.account,
           debit_account: real_account,
           credit_account: income_bucket,
           amount: 100.00,
           date: Date.today

    visit "/budget"

    # Select income bucket
    select "Salary ($100.00)", from: "budget_allocation_income_bucket_id"

    # Try to allocate more than available
    fill_in "budget_allocation[allocations][#{groceries_bucket.id}]", with: "150.00"

    # Submit the form
    click_button "Assign"

    # Verify error
    expect(page).to have_content "Insufficient balance"

    # Verify income bucket balance unchanged
    income_bucket.reload
    expect(income_bucket.balance).to eq 100.00

    # Verify groceries bucket received nothing
    groceries_bucket.reload
    expect(groceries_bucket.balance).to eq 0.00
  end

  scenario "zero-amount allocations are skipped" do
    visit "/budget"

    # Select income bucket
    select "Salary ($1,000.00)", from: "budget_allocation_income_bucket_id"

    # Only allocate to one bucket, leave others at 0
    fill_in "budget_allocation[allocations][#{groceries_bucket.id}]", with: "500.00"

    # Submit the form
    click_button "Assign"

    # Verify only 1 new entry was created (plus 1 initial)
    expect(user.account.entries.count).to eq 2

    # Verify only groceries bucket received allocation
    groceries_bucket.reload
    mortgage_bucket.reload
    savings_bucket.reload

    expect(groceries_bucket.balance).to eq 500.00
    expect(mortgage_bucket.balance).to eq 0.00
    expect(savings_bucket.balance).to eq 0.00
  end
end
