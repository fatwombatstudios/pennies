class Entry < ApplicationRecord
  belongs_to :debit_account, class_name: "Account"
  belongs_to :credit_account, class_name: "Account"
end
