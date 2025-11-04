class Entry < ApplicationRecord
  belongs_to :debit_account, class_name: "Account"
  belongs_to :credit_account, class_name: "Account"

  after_initialize :set_defaults

  before_validation :credit_and_debit_must_be_different

  private

  def set_defaults
    self.date ||= DateTime.now
    self.currency ||= :eur
  end

  def credit_and_debit_must_be_different
    if debit_account == credit_account
      errors.add(:credit_account, "must be different to the debit account")
    end
  end
end
