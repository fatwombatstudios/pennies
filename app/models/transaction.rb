class Transaction < ApplicationRecord
  after_initialize :set_defaults

  private

  def set_defaults
    self.currency ||= :eur
  end
end
