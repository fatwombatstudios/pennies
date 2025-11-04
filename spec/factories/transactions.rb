FactoryBot.define do
  factory :transaction do
    date { DateTime.now }
    amount { 100.00 }
  end
end
