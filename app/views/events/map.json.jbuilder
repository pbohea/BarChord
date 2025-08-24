# Create the main response object
json.events @events do |event|
  json.id event.id
  json.date event.date.iso8601  # Keep ISO format for consistency
  json.start_time event.start_time.iso8601
  
  # Handle optional end_time properly
  if event.end_time.present?
    json.end_time event.end_time.iso8601
  else
    json.end_time nil
  end
  
  json.description event.description
  json.cover event.cover
  json.cover_amount event.cover_amount
  json.category event.category
  json.indoors event.indoors

  json.venue do
    json.id event.venue.id
    json.slug event.venue.slug
    json.name event.venue.name
    json.category event.venue.category
    json.city event.venue.city
    
    # Create the coordinate object that iOS expects
    json.coordinate do
      json.latitude event.venue.latitude&.to_f || 0.0
      json.longitude event.venue.longitude&.to_f || 0.0
    end
    
    json.website event.venue.website
  end

json.artist do
  if event.artist.present?
    # Database artist - include full details
    json.id event.artist.id
    json.slug event.artist.slug
    json.username event.artist.username
    json.is_database_artist true
    
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
  else
    # Manual artist - limited details
    json.id nil
    json.username event.artist_name
    json.is_database_artist false
    json.image_url nil
    json.profile_url nil
  end
end
end

# Add optional centering data if provided via params
if @center_lat && @center_lng
  json.center do
    json.latitude @center_lat
    json.longitude @center_lng
  end
else
  json.center nil
end

# Add selected venue ID if provided
json.selected_venue_id @selected_venue_id
