require 'rails_helper'

RSpec.describe Bucket, type: :model do
  let(:account) { create :account }

  it "has a valid factory" do
    expect(create :bucket).to be_valid
  end

  describe "#balance" do
    context "for real accounts" do
      it "calculates balance as debits - credits" do
        real_bucket = create :bucket, account_type: :real, account: account
        other_bucket = create :bucket, account_type: :spending, account: account

        # Real account debited (money in)
        create :entry, debit_account: real_bucket, credit_account: other_bucket, amount: 100, account: account

        # Real account credited (money out)
        create :entry, debit_account: other_bucket, credit_account: real_bucket, amount: 30, account: account

        expect(real_bucket.balance).to eq 70 # 100 - 30
      end
    end

    context "for virtual accounts" do
      it "calculates balance as credits - debits" do
        savings_bucket = create :bucket, account_type: :savings, account: account
        other_bucket = create :bucket, account_type: :spending, account: account

        # Savings account credited (money saved)
        create :entry, debit_account: other_bucket, credit_account: savings_bucket, amount: 100, account: account

        # Savings account debited (money withdrawn from savings)
        create :entry, debit_account: savings_bucket, credit_account: other_bucket, amount: 30, account: account

        expect(savings_bucket.balance).to eq 70 # 100 - 30
      end
    end
  end

  describe "#virtual?" do
    it "returns true for income accounts" do
      bucket = create :bucket, account_type: :income
      expect(bucket.virtual?).to be true
    end

    it "returns true for savings accounts" do
      bucket = create :bucket, account_type: :savings
      expect(bucket.virtual?).to be true
    end

    it "returns true for spending accounts" do
      bucket = create :bucket, account_type: :spending
      expect(bucket.virtual?).to be true
    end

    it "returns false for real accounts" do
      bucket = create :bucket, account_type: :real
      expect(bucket.virtual?).to be false
    end
  end
end
