class Account < ApplicationRecord
  has_many :entries

  after_initialize :set_defaults

  enum :account_type, { real: "Real", virtual: "Virtual" }

  private

  def set_defaults
    self.account_type ||= :virtual
  end
end
