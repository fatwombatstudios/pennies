require "rails_helper"

RSpec.describe "OFX Upload", type: :feature do
  let(:user) { create :user }
  let!(:bank_account) { create :bucket, name: "Test Bank Account", account_type: :real, account: user.account }
  let!(:credit_card) { create :bucket, name: "Test Credit Card", account_type: :real, account: user.account }

  before do
    sign_in_as user
  end

  describe "upload form" do
    scenario "user can access the upload page" do
      visit upload_entries_path

      expect(page).to have_content "Upload OFX File"
      expect(page).to have_field "Select OFX File"
      expect(page).to have_select "Assign to Real Account"
      expect(page).to have_button "Upload and Import"
    end

    scenario "user sees all real accounts in the dropdown" do
      visit upload_entries_path

      expect(page).to have_select("Assign to Real Account", with_options: [ bank_account.name, credit_card.name ])
    end
  end

  describe "validations" do
    scenario "user cannot submit without selecting a file" do
      visit upload_entries_path

      select bank_account.name, from: "Assign to Real Account"
      click_button "Upload and Import"

      expect(page).to have_content "Please select an OFX file to upload"
    end

    scenario "user cannot submit without selecting an account" do
      visit upload_entries_path

      attach_file "Select OFX File", Rails.root.join("spec/fixtures/files/test_bank_account.ofx")
      click_button "Upload and Import"

      expect(page).to have_content "Please select a real account"
    end
  end

  describe "uploading bank account OFX file" do
    scenario "user successfully uploads and imports transactions" do
      visit upload_entries_path

      attach_file "Select OFX File", Rails.root.join("spec/fixtures/files/test_bank_account.ofx")
      select bank_account.name, from: "Assign to Real Account"

      expect {
        click_button "Upload and Import"
      }.to change { Entry.count }.by(5)

      expect(page).to have_content "Successfully imported 5 transactions"
      expect(current_path).to eq(entries_path)
    end

    scenario "creates system buckets automatically" do
      visit upload_entries_path

      attach_file "Select OFX File", Rails.root.join("spec/fixtures/files/test_bank_account.ofx")
      select bank_account.name, from: "Assign to Real Account"

      expect {
        click_button "Upload and Import"
      }.to change { Bucket.where(system: true).count }.by(2)

      unknown_income = Bucket.find_by(name: "Unknown Income", system: true, account: user.account)
      unknown_expense = Bucket.find_by(name: "Unknown Expense", system: true, account: user.account)

      expect(unknown_income).to be_present
      expect(unknown_income.account_type).to eq("income")

      expect(unknown_expense).to be_present
      expect(unknown_expense.account_type).to eq("spending")
    end

    scenario "creates correct entries for income transactions (DIRECTDEP, CREDIT)" do
      visit upload_entries_path

      attach_file "Select OFX File", Rails.root.join("spec/fixtures/files/test_bank_account.ofx")
      select bank_account.name, from: "Assign to Real Account"
      click_button "Upload and Import"

      # Check salary transaction (DIRECTDEP)
      salary_entry = Entry.find_by(description: "SALARY PAYMENT FROM ACME CORP")
      expect(salary_entry).to be_present
      expect(salary_entry.amount).to eq(2500.00)
      expect(salary_entry.debit_account).to eq(bank_account) # Real account debited
      expect(salary_entry.credit_account.name).to eq("Unknown Income") # Income bucket credited
      expect(salary_entry.action).to eq(:income)

      # Check refund transaction (CREDIT)
      refund_entry = Entry.find_by(description: "REFUND FROM XYZ STORE")
      expect(refund_entry).to be_present
      expect(refund_entry.amount).to eq(75.50)
      expect(refund_entry.debit_account).to eq(bank_account)
      expect(refund_entry.credit_account.name).to eq("Unknown Income")
      expect(refund_entry.action).to eq(:income)

      # Check interest payment (OTHER with positive amount)
      interest_entry = Entry.find_by(description: "INTEREST PAYMENT")
      expect(interest_entry).to be_present
      expect(interest_entry.amount).to eq(25.00)
      expect(interest_entry.debit_account).to eq(bank_account)
      expect(interest_entry.credit_account.name).to eq("Unknown Income")
      expect(interest_entry.action).to eq(:income)
    end

    scenario "creates correct entries for expense transactions (DEBIT)" do
      visit upload_entries_path

      attach_file "Select OFX File", Rails.root.join("spec/fixtures/files/test_bank_account.ofx")
      select bank_account.name, from: "Assign to Real Account"
      click_button "Upload and Import"

      # Check transfer transaction (negative DEBIT)
      transfer_entry = Entry.find_by(description: "TRANSFER TO SAVINGS ACCOUNT")
      expect(transfer_entry).to be_present
      expect(transfer_entry.amount).to eq(150.00)
      expect(transfer_entry.debit_account.name).to eq("Unknown Expense") # Expense bucket debited
      expect(transfer_entry.credit_account).to eq(bank_account) # Real account credited
      expect(transfer_entry.action).to eq(:expense)

      # Check online purchase (negative DEBIT)
      purchase_entry = Entry.find_by(description: "ONLINE PURCHASE - AMAZON")
      expect(purchase_entry).to be_present
      expect(purchase_entry.amount).to eq(89.99)
      expect(purchase_entry.debit_account.name).to eq("Unknown Expense")
      expect(purchase_entry.credit_account).to eq(bank_account)
      expect(purchase_entry.action).to eq(:expense)
    end

    scenario "correctly sets currency and date" do
      visit upload_entries_path

      attach_file "Select OFX File", Rails.root.join("spec/fixtures/files/test_bank_account.ofx")
      select bank_account.name, from: "Assign to Real Account"
      click_button "Upload and Import"

      salary_entry = Entry.find_by(description: "SALARY PAYMENT FROM ACME CORP")
      expect(salary_entry.currency).to eq("aud")
      expect(salary_entry.date.to_date).to eq(Date.new(2025, 1, 3))
    end
  end

  describe "uploading credit card OFX file" do
    scenario "user successfully uploads and imports credit card transactions" do
      visit upload_entries_path

      attach_file "Select OFX File", Rails.root.join("spec/fixtures/files/test_credit_card.ofx")
      select credit_card.name, from: "Assign to Real Account"

      expect {
        click_button "Upload and Import"
      }.to change { Entry.count }.by(4)

      expect(page).to have_content "Successfully imported 4 transactions"
    end

    scenario "creates correct entries for credit card expenses (negative DEBIT)" do
      visit upload_entries_path

      attach_file "Select OFX File", Rails.root.join("spec/fixtures/files/test_credit_card.ofx")
      select credit_card.name, from: "Assign to Real Account"
      click_button "Upload and Import"

      # Check grocery purchase
      grocery_entry = Entry.find_by(description: "GROCERY STORE - WOOLWORTHS")
      expect(grocery_entry).to be_present
      expect(grocery_entry.amount).to eq(45.00)
      expect(grocery_entry.debit_account.name).to eq("Unknown Expense")
      expect(grocery_entry.credit_account).to eq(credit_card)
      expect(grocery_entry.action).to eq(:expense)

      # Check restaurant purchase
      restaurant_entry = Entry.find_by(description: "RESTAURANT - MAIN STREET CAFE")
      expect(restaurant_entry).to be_present
      expect(restaurant_entry.amount).to eq(120.00)
      expect(restaurant_entry.debit_account.name).to eq("Unknown Expense")
      expect(restaurant_entry.credit_account).to eq(credit_card)
      expect(restaurant_entry.action).to eq(:expense)
    end

    scenario "creates correct entries for credit card credits (positive CREDIT)" do
      visit upload_entries_path

      attach_file "Select OFX File", Rails.root.join("spec/fixtures/files/test_credit_card.ofx")
      select credit_card.name, from: "Assign to Real Account"
      click_button "Upload and Import"

      # Check payment reversal (credit)
      reversal_entry = Entry.find_by(description: "PAYMENT REVERSAL - WOOLWORTHS")
      expect(reversal_entry).to be_present
      expect(reversal_entry.amount).to eq(45.00)
      expect(reversal_entry.debit_account).to eq(credit_card)
      expect(reversal_entry.credit_account.name).to eq("Unknown Income")
      expect(reversal_entry.action).to eq(:income)
    end
  end

  describe "system buckets reuse" do
    scenario "does not create duplicate system buckets on subsequent uploads" do
      # First upload
      visit upload_entries_path
      attach_file "Select OFX File", Rails.root.join("spec/fixtures/files/test_bank_account.ofx")
      select bank_account.name, from: "Assign to Real Account"
      click_button "Upload and Import"

      system_buckets_count = Bucket.where(system: true, account: user.account).count
      expect(system_buckets_count).to eq(2)

      # Second upload
      visit upload_entries_path
      attach_file "Select OFX File", Rails.root.join("spec/fixtures/files/test_credit_card.ofx")
      select credit_card.name, from: "Assign to Real Account"

      expect {
        click_button "Upload and Import"
      }.not_to change { Bucket.where(system: true, account: user.account).count }

      expect(Bucket.where(system: true, account: user.account).count).to eq(2)
    end
  end
end
