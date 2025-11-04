json.extract! tx, :id, :date, :amount, :currency, :description, :created_at, :updated_at
json.url tx_url(tx, format: :json)
