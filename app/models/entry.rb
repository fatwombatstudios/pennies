class Entry < ApplicationRecord
  belongs_to :account
  belongs_to :debit_account, class_name: "Bucket"
  belongs_to :credit_account, class_name: "Bucket"

  after_initialize :set_defaults

  validates :amount, presence: true, numericality: { greater_than: 0 }

  before_validation :must_have_an_account
  before_validation :credit_and_debit_must_be_different

  def action
    return nil unless debit_account && credit_account

    return :income if debit_account.real? && credit_account.virtual?
    return :expense if debit_account.virtual? && credit_account.real?

    :transfer
  end

  def from_account_id
    case action
    when :income
      credit_account_id # Income bucket
    when :expense
      debit_account_id # Spending bucket
    when :transfer
      # For real-to-real: from is credit (money leaves)
      # For virtual-to-virtual: from is debit (budget decreases)
      debit_account&.real? ? credit_account_id : debit_account_id
    end
  end

  def to_account_id
    case action
    when :income
      debit_account_id # Real account
    when :expense
      credit_account_id # Real account
    when :transfer
      # For real-to-real: to is debit (money arrives)
      # For virtual-to-virtual: to is credit (budget increases)
      debit_account&.real? ? debit_account_id : credit_account_id
    end
  end

  private

  def set_defaults
    self.date ||= DateTime.now
    self.currency ||= :eur
  end

  def must_have_an_account
    self.account_id ||= debit_account.account_id
  end

  def credit_and_debit_must_be_different
    if debit_account == credit_account
      errors.add(:credit_account, "must be different to the debit account")
    end
  end
end
