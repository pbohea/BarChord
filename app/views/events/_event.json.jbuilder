json.extract! event, :id, :category, :cover, :date, :description, :start_time, :end_time, :indoors, :artist_id, :venue_id, :created_at, :updated_at
json.url event_url(event, format: :json)
