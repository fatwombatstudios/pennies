require "rails_helper"

RSpec.describe Account do
  let(:account) { create :account }

  it "has a valid factory" do
    expect(create :account).to be_valid
  end

  describe "#buckets" do
    it "only lists an account's user generated buckets" do
      system = create :bucket, account: account, name: "Unknown", account_type: :income, system: :true
      salary = create :bucket, account: account, name: "Salary", account_type: :income

      expect(account.custom_buckets).to include salary
      expect(account.custom_buckets).not_to include system
    end

    it "gets an account's system income and expense account" do
      salary = create :bucket, account: account, name: "Salary", account_type: :income
      income = create :bucket, account: account, name: "Unknown", account_type: :income, system: :true
      expense = create :bucket, account: account, name: "Unknown", account_type: :spending, system: :true

      expect(account.system_buckets).to include income
      expect(account.system_buckets).to include expense
      expect(account.system_buckets).not_to include salary
    end
  end
end
