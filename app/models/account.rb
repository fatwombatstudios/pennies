class Account < ApplicationRecord
  has_many :users
  has_many :buckets
  has_many :entries

  def custom_buckets
    buckets.where(system: false)
  end

  def system_buckets
    buckets.where(system: true)
  end
end
