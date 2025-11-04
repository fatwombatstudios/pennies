FactoryBot.define do
  factory :entry do
    date { "2025-11-04 17:42:03" }
    currency { "MyString" }
    amount { "9.99" }
    debit_account { nil }
    credit_account { nil }
  end
end
