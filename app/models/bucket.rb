class Bucket < ApplicationRecord
  belongs_to :account

  has_many :debits, class_name: "Entry", foreign_key: :debit_account_id
  has_many :credits, class_name: "Entry", foreign_key: :credit_account_id

  after_initialize :set_defaults

  enum :account_type, { income: "Income", savings: "Savings", spending: "Spending", real: "Real" }

  def balance
    d = debits.map { |e| e.amount }.sum
    c = credits.map { |e| e.amount }.sum

    virtual? ? c - d : d - c
  end

  def virtual?
    income? || savings? || spending?
  end

  private

  def set_defaults
    self.account_type ||= :spending
  end
end
