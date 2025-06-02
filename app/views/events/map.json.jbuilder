json.array! @events do |event|
  json.id event.id
  json.date event.date.strftime("%A, %B %-d")
  json.start_time event.start_time.strftime("%-I:%M %p")
  json.end_time event.end_time.strftime("%-I:%M %p")
  json.description event.description
  json.cover event.cover
  json.cover_amount event.cover_amount
  json.category event.category
  json.indoors event.indoors

  json.label(
    event.venue.name || event.artist&.username.presence 
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
    json.image_url event.artist.image.attached? ? rails_blob_url(event.artist.image) : nil
    json.profile_url artist_url(event.artist)
  end

end
