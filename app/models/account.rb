class Account < ApplicationRecord
  has_many :users
  has_many :buckets
  has_many :entries
end
