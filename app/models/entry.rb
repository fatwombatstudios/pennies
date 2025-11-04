class Entry < ApplicationRecord
  belongs_to :debit_account
  belongs_to :credit_account
end
