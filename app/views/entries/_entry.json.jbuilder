json.extract! entry, :id, :date, :currency, :amount, :debit_account_id, :credit_account_id, :created_at, :updated_at
json.url entry_url(entry, format: :json)
