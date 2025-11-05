class Bucket < ApplicationRecord
  belongs_to :account

  has_many :debits, class_name: "Entry", foreign_key: :debit_account_id
  has_many :credits, class_name: "Entry", foreign_key: :credit_account_id

  after_initialize :set_defaults

  enum :account_type, { real: "Real", virtual: "Virtual" }

  def balance
    d = debits.map { |e| e.amount }.sum
    c = credits.map { |e| e.amount }.sum

    virtual? ? c - d : d - c
  end

  private

  def set_defaults
    self.account_type ||= :virtual
  end
end
