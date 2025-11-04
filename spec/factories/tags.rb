FactoryBot.define do
  factory :tag do
    name { "Savings" }
    association :tx
  end
end
