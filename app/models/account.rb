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

  # Ensure system buckets exist for OFX imports
  # Returns hash with :income and :expense keys pointing to the system buckets
  def ensure_system_buckets!
    {
      income: buckets.find_or_create_by!(
        name: "Unknown Income",
        system: true,
        account_type: :income
      ) { |b| b.description = "System bucket for unclassified income from OFX imports" },
      expense: buckets.find_or_create_by!(
        name: "Unknown Expense",
        system: true,
        account_type: :spending
      ) { |b| b.description = "System bucket for unclassified expenses from OFX imports" }
    }
  end
end
