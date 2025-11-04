require 'rails_helper'

RSpec.describe Entry, type: :model do
  it "has a valid factory" do
    expect(create :entry).to be_valid
  end

  it "wont allow debit and credit accounts to be the same" do
    account = create :account
    entry = build :entry, debit_account: account, credit_account: account

    expect(entry).not_to be_valid
    expect(entry.errors.first.full_message).to include "Credit account must be different to the debit account"
  end
end
