require 'rails_helper'

RSpec.describe Entry, type: :model do
  it "has a valid factory" do
    expect(create :entry).to be_valid
  end

  it "wont allow debit and credit accounts to be the same" do
    bucket = create :bucket
    entry = build :entry, debit_account: bucket, credit_account: bucket

    expect(entry).not_to be_valid
    expect(entry.errors.first.full_message).to include "Credit account must be different to the debit account"
  end

  describe "#action" do
    let(:account) { create :account }
    let(:real_bucket) { create :bucket, account: account, account_type: :real }
    let(:virtual_bucket) { create :bucket, account: account, account_type: :spending }
    let(:another_real_bucket) { create :bucket, account: account, account_type: :real }
    let(:another_virtual_bucket) { create :bucket, account: account, account_type: :income }

    context "when real debit and virtual credit" do
      it "returns :income" do
        entry = create :entry, debit_account: real_bucket, credit_account: virtual_bucket
        expect(entry.action).to eq(:income)
      end
    end

    context "when virtual debit and real credit" do
      it "returns :expense" do
        entry = create :entry, debit_account: virtual_bucket, credit_account: real_bucket
        expect(entry.action).to eq(:expense)
      end
    end

    context "when real debit and real credit" do
      it "returns :transfer" do
        entry = create :entry, debit_account: real_bucket, credit_account: another_real_bucket
        expect(entry.action).to eq(:transfer)
      end
    end

    context "when virtual debit and virtual credit" do
      it "returns :transfer" do
        entry = create :entry, debit_account: virtual_bucket, credit_account: another_virtual_bucket
        expect(entry.action).to eq(:transfer)
      end
    end
  end
end
