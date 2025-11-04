FactoryBot.define do
  factory :entry do
    amount { "9.99" }
    association :debit_account, factory: :account
    association :credit_account, factory: :account
  end
end
