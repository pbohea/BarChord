json.array! @events do |event|
  json.id event.id
  json.date event.date.strftime("%A, %B %-d")
  json.start_time event.start_time.strftime("%-I:%M %p")
  
  # Handle optional end_time properly
  if event.end_time.present?
    json.end_time event.end_time.strftime("%-I:%M %p")
  else
    json.end_time nil
  end
  
  json.description event.description
  json.cover event.cover
  json.cover_amount event.cover_amount
  json.category event.category
  json.indoors event.indoors

  # Create a fallback label
  json.label(
    event.venue&.name.presence || event.artist&.username.presence || "Unnamed Event"
  )

  json.venue do
    json.id event.venue.id
    json.name event.venue.name
    json.category event.venue.category
    
    # Ensure coordinates are valid numbers
    json.latitude event.venue.latitude&.to_f || 0.0
    json.longitude event.venue.longitude&.to_f || 0.0
    
    json.website event.venue.website
  end

  json.artist do
    json.id event.artist.id
    json.username event.artist.username
    
    # Handle image URL properly
    if event.artist.image.attached?
      json.image_url rails_blob_url(event.artist.image)
    else
      json.image_url nil
    end
    
    # Handle profile URL
    begin
      json.profile_url artist_url(event.artist)
    rescue => e
      Rails.logger.warn "Failed to generate artist URL for artist #{event.artist.id}: #{e.message}"
      json.profile_url nil
    end
  end
end
