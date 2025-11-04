FactoryBot.define do
  factory :tx do
    date { Datetime.now }
    amount { "9.99" }
  end
end
