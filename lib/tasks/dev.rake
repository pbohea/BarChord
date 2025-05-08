desc "Fill the database tables with some sample data"
task sample_data: :environment do
  require "faker"

  if Rails.env.development?
    puts "Deleting existing records..."
    Event.destroy_all
    Venue.destroy_all
    Artist.destroy_all
    User.destroy_all
    Owner.destroy_all
  end

  
  # Create Owners first
  owners = []
  10.times do
    owner_name = Faker::Name.first_name
    owners << Owner.create!(
      name: owner_name,
      email: "#{owner_name.downcase}_owner@example.com",
      password: "password"
    )
  end

  # Create Users
  10.times do
    User.create!(
      email: "#{Faker::Name.first_name.downcase}_user@example.com",
      password: "password"
    )
  end

  # Create Artists
  artists = []
  10.times do
    artist_name = Faker::Name.first_name
    artists << Artist.create!(
      name: artist_name,
      email: "#{artist_name.downcase}_artist@example.com",
      password: "password",
      genre: Faker::Music.genre,
      website: "www.google.com",
      image: Faker::LoremFlickr.image(size: "50x60")
    )
  end

  venues = []  
  10.times do
    v = Venue.new
    
    v.name = Faker::Company.name
    v.address = Faker::Address.full_address
    v.category = Faker::Restaurant.type
    v.website = "www.google.com"
    v.image = Faker::LoremFlickr.image(size: "50x60")
    v.owner_id = owners.sample.id  
    
    address = v.address

    api_url = "https://api.mapbox.com/search/geocode/v6/forward?q=#{address}&access_token=#{ENV.fetch('MAPBOX_ACCESS_TOKEN')}"
    raw_response = HTTP.get(api_url)
    parsed_data = JSON.parse(raw_response)

    coordinates = parsed_data.fetch("features").at(0).fetch("geometry").fetch("coordinates")
    longitude = coordinates.at(0)
    latitude = coordinates.at(1)

    v.latitude = latitude
    v.longitude = longitude
    v.save
    venues << v
  end


  10.times do
    start_time = Faker::Time.between(from: DateTime.now + 12.hours, to: DateTime.now + 24.hours)
    Event.create!(
      category: Faker::Music.instrument,
      date: Faker::Date.forward(days: 1),
      start_time: start_time,
      end_time: start_time + 3.hours,
      description: Faker::Lorem.characters(number: 12),
      cover: Faker::Boolean.boolean(true_ratio: 0.2),
      venue_id: venues.sample.id,
      artist_id: artists.sample.id  
      )
    end
end
