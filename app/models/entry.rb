class Entry < ApplicationRecord
  belongs_to :debit_account, class_name: "Account"
  belongs_to :credit_account, class_name: "Account"

  after_initialize :set_defaults

  private

  def set_defaults
    self.currency ||= :eur
  end
end
