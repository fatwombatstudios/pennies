class Entry < ApplicationRecord
  belongs_to :account
  belongs_to :debit_account, class_name: "Bucket"
  belongs_to :credit_account, class_name: "Bucket"

  after_initialize :set_defaults

  before_validation :must_have_an_account
  before_validation :credit_and_debit_must_be_different

  def income?
    debit_account.real? && credit_account.virtual?
  end

  def expense?
    debit_account.virtual? && credit_account.real?
  end

  def allocation?
    !income? && !expense?
  end

  def entry_type
    return :income if income?
    return :expense if expense?

    :allocation
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
