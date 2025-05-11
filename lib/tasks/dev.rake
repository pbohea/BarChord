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
      password: "password",
    )
  end

  #users
  10.times do
    name = Faker::Name.first_name
    User.create!(
      email: "#{name.downcase}_user@example.com",
      password: "password",
      username: "#{name.downcase}_fan",
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

=begin
  #VENUES WITH GOOGLE MAPS API
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
=end

  #VENUES WITH NO GOOGLEMAPS API
  venues = []

  manual_venues = [
    {
      name: "The Broken Oar",
      address: "614 Rawson Bridge Rd, Port Barrington, IL 60010",
      category: "Bar",
      website: "https://brokenoar.com",
      latitude: 42.2472,
      longitude: -88.1929,
    },
    {
      name: "Durty Nellie's",
      address: "180 N Smith St, Palatine, IL 60067",
      category: "Irish Pub",
      website: "https://durtynellies.com",
      latitude: 42.1126,
      longitude: -88.0490,
    },
    {
      name: "The Hideout",
      address: "1354 W Wabansia Ave, Chicago, IL 60642",
      category: "Music Venue",
      website: "https://hideoutchicago.com",
      latitude: 41.9132,
      longitude: -87.6622,
    },
    {
      name: "Martyrs'",
      address: "3855 N Lincoln Ave, Chicago, IL 60613",
      category: "Live Music Bar",
      website: "https://martyrslive.com",
      latitude: 41.9510,
      longitude: -87.6792,
    },
    {
      name: "FitzGerald’s",
      address: "6615 W Roosevelt Rd, Berwyn, IL 60402",
      category: "Jazz Club",
      website: "https://www.fitzgeraldsnightclub.com",
      latitude: 41.8649,
      longitude: -87.7884,
    },
    {
      name: "The Empty Bottle",
      address: "1035 N Western Ave, Chicago, IL 60622",
      category: "Indie Music Venue",
      website: "https://emptybottle.com",
      latitude: 41.9002,
      longitude: -87.6861,
    },
  ]

  manual_venues.each do |venue_attrs|
    venue = Venue.create!(
      name: venue_attrs[:name],
      address: venue_attrs[:address],
      category: venue_attrs[:category],
      website: venue_attrs[:website],
      owner_id: owners.sample.id,
      latitude: venue_attrs[:latitude],
      longitude: venue_attrs[:longitude],
    )
    venues << venue
  end

  # events
  10.times do
    start_time = Faker::Time.between(from: DateTime.now + 12.hours, to: DateTime.now + 1.day)
    cover = [true, false].sample

    Event.create!(
      category: Faker::Music.instrument,
      date: start_time.to_date,
      start_time: start_time,
      end_time: start_time + 2.hours,
      description: Faker::Lorem.sentence(word_count: 6),
      cover: cover,
      cover_amount: cover ? rand(5..20) : nil,
      indoors: [true, false].sample,
      venue_id: venues.sample.id,
      artist_id: artists.sample.id,
    )
  end
end
