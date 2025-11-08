require 'rails_helper'

RSpec.describe Bucket, type: :model do
  it "has a valid factory" do
    expect(create :bucket).to be_valid
  end

  it "lists buckets by type" do
    income = create_list :bucket, 3, account_type: :income
    spending = create_list :bucket, 3, account_type: :spending

    expect(Bucket.income).to eq income
    expect(Bucket.spending).to eq spending
  end
end
