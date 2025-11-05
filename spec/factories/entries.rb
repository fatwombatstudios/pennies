FactoryBot.define do
  factory :entry do
    amount { "9.99" }

    association :debit_account, factory: :bucket
    association :credit_account, factory: :bucket
    association :account
  end
end
