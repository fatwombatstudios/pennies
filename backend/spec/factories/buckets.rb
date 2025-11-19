FactoryBot.define do
  factory :bucket do
    name { "Savings" }

    association :account
  end
end
