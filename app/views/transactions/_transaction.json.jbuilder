json.extract! transaction, :id, :date, :amount, :current, :description, :created_at, :updated_at
json.url transaction_url(transaction, format: :json)
