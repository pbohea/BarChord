json.array! @events do |event|
  json.extract! event, :id, :name, :date, :start_time

  json.venue do
    json.name event.venue.name
    json.latitude event.venue.latitude
    json.longitude event.venue.longitude
  end
end
