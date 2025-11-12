require "rails_helper"

RSpec.describe OfxTransactionImportService, type: :service do
  let(:account) { create(:account) }
  let(:real_account) { create(:bucket, account: account, account_type: :real, name: "Checking") }
  let(:ofx_file) { File.open(Rails.root.join("spec/fixtures/files/test_bank_account.ofx")) }

  subject(:service) do
    described_class.new(
      account: account,
      ofx_file: ofx_file,
      real_account: real_account
    )
  end

  describe "#import" do
    context "with valid OFX file" do
      it "returns a successful result" do
        result = service.import

        expect(result).to be_success
      end

      it "creates entries from OFX transactions" do
        expect {
          service.import
        }.to change { Entry.count }.by(5)
      end

      it "returns the number of entries created" do
        result = service.import

        expect(result.data[:entries_created]).to eq(5)
      end

      it "creates system buckets if they don't exist" do
        expect {
          service.import
        }.to change { Bucket.where(system: true, account: account).count }.by(2)

        expect(Bucket.find_by(name: "Unknown Income", system: true, account: account)).to be_present
        expect(Bucket.find_by(name: "Unknown Expense", system: true, account: account)).to be_present
      end

      it "reuses existing system buckets" do
        # Create system buckets first
        account.ensure_system_buckets!

        expect {
          service.import
        }.not_to change { Bucket.where(system: true, account: account).count }
      end
    end

    context "creating income entries" do
      before do
        service.import
      end

      it "creates income entries with correct debit and credit accounts" do
        # DIRECTDEP transaction
        salary_entry = Entry.find_by(description: "SALARY PAYMENT FROM ACME CORP")

        expect(salary_entry).to be_present
        expect(salary_entry.debit_account).to eq(real_account)
        expect(salary_entry.credit_account.name).to eq("Unknown Income")
        expect(salary_entry.action).to eq(:income)
      end

      it "sets correct amount from OFX transaction" do
        salary_entry = Entry.find_by(description: "SALARY PAYMENT FROM ACME CORP")

        expect(salary_entry.amount).to eq(2500.00)
      end

      it "sets correct date from OFX transaction" do
        salary_entry = Entry.find_by(description: "SALARY PAYMENT FROM ACME CORP")

        expect(salary_entry.date.to_date).to eq(Date.new(2025, 1, 3))
      end

      it "sets correct currency from OFX transaction" do
        salary_entry = Entry.find_by(description: "SALARY PAYMENT FROM ACME CORP")

        expect(salary_entry.currency).to eq("aud")
      end

      it "handles CREDIT type income transactions" do
        refund_entry = Entry.find_by(description: "REFUND FROM XYZ STORE")

        expect(refund_entry).to be_present
        expect(refund_entry.debit_account).to eq(real_account)
        expect(refund_entry.credit_account.name).to eq("Unknown Income")
      end

      it "handles OTHER type income transactions with positive amount" do
        interest_entry = Entry.find_by(description: "INTEREST PAYMENT")

        expect(interest_entry).to be_present
        expect(interest_entry.debit_account).to eq(real_account)
        expect(interest_entry.credit_account.name).to eq("Unknown Income")
      end
    end

    context "creating expense entries" do
      before do
        service.import
      end

      it "creates expense entries with correct debit and credit accounts" do
        transfer_entry = Entry.find_by(description: "TRANSFER TO SAVINGS ACCOUNT")

        expect(transfer_entry).to be_present
        expect(transfer_entry.debit_account.name).to eq("Unknown Expense")
        expect(transfer_entry.credit_account).to eq(real_account)
        expect(transfer_entry.action).to eq(:expense)
      end

      it "handles negative DEBIT transactions as expenses" do
        purchase_entry = Entry.find_by(description: "ONLINE PURCHASE - AMAZON")

        expect(purchase_entry).to be_present
        expect(purchase_entry.amount).to eq(89.99)
        expect(purchase_entry.debit_account.name).to eq("Unknown Expense")
        expect(purchase_entry.credit_account).to eq(real_account)
      end
    end

    context "with credit card OFX file" do
      let(:ofx_file) { File.open(Rails.root.join("spec/fixtures/files/test_credit_card.ofx")) }
      let(:credit_card) { create(:bucket, account: account, account_type: :real, name: "Credit Card") }

      subject(:service) do
        described_class.new(
          account: account,
          ofx_file: ofx_file,
          real_account: credit_card
        )
      end

      it "creates entries from credit card transactions" do
        expect {
          service.import
        }.to change { Entry.count }.by(4)
      end

      it "handles credit card expenses correctly" do
        service.import

        grocery_entry = Entry.find_by(description: "GROCERY STORE - WOOLWORTHS")

        expect(grocery_entry).to be_present
        expect(grocery_entry.amount).to eq(45.00)
        expect(grocery_entry.debit_account.name).to eq("Unknown Expense")
        expect(grocery_entry.credit_account).to eq(credit_card)
      end

      it "handles credit card credits correctly" do
        service.import

        reversal_entry = Entry.find_by(description: "PAYMENT REVERSAL - WOOLWORTHS")

        expect(reversal_entry).to be_present
        expect(reversal_entry.debit_account).to eq(credit_card)
        expect(reversal_entry.credit_account.name).to eq("Unknown Income")
      end
    end

    context "with invalid entry data" do
      let(:mock_importer) { instance_double(OfxImporterService) }
      let(:invalid_transaction) do
        {
          date: Date.today,
          amount: -100, # Invalid: negative amount
          currency: "AUD",
          action: "Expense",
          description: "Invalid transaction",
          fitid: "123"
        }
      end

      before do
        allow_any_instance_of(OfxTransactionImportService).to receive(:parse_ofx_file).and_return([ invalid_transaction ])
      end

      it "returns failure result when entries fail to save" do
        result = service.import

        expect(result).not_to be_success
      end

      it "includes error messages in result" do
        result = service.import

        expect(result.errors).to be_present
        expect(result.errors.first).to include("Transaction 123")
      end

      it "still reports partial success" do
        valid_transaction = {
          date: Date.today,
          amount: 100,
          currency: "AUD",
          action: "Income",
          description: "Valid transaction",
          fitid: "456"
        }

        allow_any_instance_of(OfxTransactionImportService).to receive(:parse_ofx_file).and_return([
          valid_transaction,
          invalid_transaction
        ])

        result = service.import

        expect(result.data[:entries_created]).to eq(1)
        expect(result.errors.count).to eq(1)
      end
    end
  end

  describe "result structure" do
    it "returns a ServiceSignature::Result object" do
      result = service.import

      expect(result).to be_a(ServiceSignature::Result)
    end

    it "includes data hash with entries_created key" do
      result = service.import

      expect(result.data).to be_a(Hash)
      expect(result.data).to have_key(:entries_created)
    end
  end
end
