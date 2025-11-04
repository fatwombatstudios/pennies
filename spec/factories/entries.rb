FactoryBot.define do
  factory :entry do
    date { DateTime.now }
    amount { "9.99" }
    association :debit_account, factory: :account
    association :credit_account, factory: :account
  end
end
