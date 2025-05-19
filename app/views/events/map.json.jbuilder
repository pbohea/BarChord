json.array! @events do |event|
  json.id event.id
  json.date event.date
  json.start_time event.start_time
  json.end_time event.end_time
  json.description event.description
  json.cover event.cover
  json.cover_amount event.cover_amount
  json.category event.category
  json.indoors event.indoors

  json.label(
    event.artist&.username.presence || event.venue.name
  )

  json.venue do
    json.name event.venue.name
    json.id event.venue.id
    json.category event.venue.category
    json.latitude event.venue.latitude
    json.longitude event.venue.longitude
    json.website event.venue.website
  end

    json.artist do
    json.id event.artist.id
    json.username event.artist.username
    json.image_url url_for(event.artist.image) if event.artist.image.attached?
    json.profile_url artist_url(event.artist)
  end

end
