json.extract! query, :id, :url, :created_at, :updated_at
json.url query_url(query, format: :json)