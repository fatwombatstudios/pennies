FactoryBot.define do
  factory :entry do
    date { "2025-11-04 17:42:03" }
    currency { "MyString" }
    amount { "9.99" }
    association :debit_account, factory: :account
    association :credit_account, factory: :account
  end
end
