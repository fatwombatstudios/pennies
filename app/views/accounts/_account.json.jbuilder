json.extract! account, :id, :name, :description, :account_type, :created_at, :updated_at
json.url account_url(account, format: :json)
