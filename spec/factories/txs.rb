FactoryBot.define do
  factory :tx do
    date { DateTime.now }
    amount { "9.99" }
  end
end
