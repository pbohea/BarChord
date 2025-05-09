desc "Fill the database tables with some sample data"
task sample_data: :environment do
  require "faker"
  require "http"
  require "uri"

  if Rails.env.development?
    puts "Deleting existing records..."
    Event.destroy_all
    Venue.destroy_all
    Artist.destroy_all
    User.destroy_all
    Owner.destroy_all
  end

  #owners
  owners = []
  10.times do
    name = Faker::Name.first_name
    owners << Owner.create!(
      firstname: name,
      email: "#{name.downcase}_owner@example.com",
      password: "password"
    )
  end

  #users
  10.times do
    name = Faker::Name.first_name
    User.create!(
      email: "#{name.downcase}_user@example.com",
      password: "password",
      username: "#{name.downcase}_fan"
    )
  end

  #artists
  artists = []
  10.times do
    name = Faker::Name.first_name
    artists << Artist.create!(
      firstname: name,
      email: "#{name.downcase}_artist@example.com",
      password: "password",
      username: "#{name.downcase}_music",
      genre: Faker::Music.genre,
      website: "https://example.com",
    )
  end

  #venues
  venues = []
  10.times do
    address = Faker::Address.full_address
    name = Faker::Company.name

    #geocoding
    escaped_address = URI.encode_www_form_component(address)
    api_key = ENV.fetch("GOOGLE_MAPS_API_KEY")
    url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{escaped_address}&key=#{api_key}"

    response = HTTP.get(url)
    parsed = JSON.parse(response)

    if parsed["status"] == "OK"
      location = parsed["results"][0]["geometry"]["location"]
      lat = location["lat"]
      lng = location["lng"]

      venue = Venue.create!(
        name: name,
        address: address,
        category: Faker::Restaurant.type,
        website: "https://example.com",
        owner_id: owners.sample.id,
        latitude: lat,
        longitude: lng
      )
      venues << venue
    else
      puts "Could not geocode: #{address} (Status: #{parsed["status"]})"
    end
  end

  #events
  10.times do
    start_time = Faker::Time.between(from: DateTime.now + 12.hours, to: DateTime.now + 1.day)
    Event.create!(
      category: Faker::Music.instrument,
      date: start_time.to_date,
      start_time: start_time,
      end_time: start_time + 2.hours,
      description: Faker::Lorem.sentence(word_count: 6),
      cover: [true, false].sample,
      indoors: [true, false].sample,
      venue_id: venues.sample.id,
      artist_id: artists.sample.id
    )
  end

end
