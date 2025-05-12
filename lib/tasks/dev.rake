desc "Fill the database tables with some sample data"
task sample_data: :environment do
  require "faker"
  require "http"
  require "uri"

  if Rails.env.development?
    puts "Deleting existing records..."
    Event.destroy_all
    VenueFollow.delete_all
    Venue.destroy_all
    ArtistFollow.delete_all
    Artist.destroy_all
    User.destroy_all
    Owner.destroy_all
    
  end

  #safety switch for geocoding
  Venue.skip_callback(:save, :before, :geocode_address)

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

  #VENUES WITH NO GOOGLEMAPS API
  venues = []

  manual_venues = [
    {
      name: "The Green Mill",
      street_address: "4802 N Broadway",
      city: "Chicago",
      state: "IL",
      zip_code: "60640",
      category: "Music Hall",
      website: "https://greenmilljazz.com",
      latitude: 41.9701,
      longitude: -87.6598,
    },
    {
      name: "Schubas Tavern",
      street_address: "3159 N Southport Ave",
      city: "Chicago",
      state: "IL",
      zip_code: "60657",
      category: "Club",
      website: "https://lh-st.com/venues/schubas-tavern",
      latitude: 41.9409,
      longitude: -87.6636,
    },
    {
      name: "Constellation",
      street_address: "3111 N Western Ave",
      city: "Chicago",
      state: "IL",
      zip_code: "60618",
      category: "Bar",
      website: "https://constellation-chicago.com",
      latitude: 41.9383,
      longitude: -87.6889,
    },
    {
      name: "Reggies Rock Club",
      street_address: "2109 S State St",
      city: "Chicago",
      state: "IL",
      zip_code: "60616",
      category: "Music Hall",
      website: "https://reggieslive.com",
      latitude: 41.8539,
      longitude: -87.6272,
    },
    {
      name: "Hideout Inn",
      street_address: "1354 W Wabansia Ave",
      city: "Chicago",
      state: "IL",
      zip_code: "60642",
      category: "Club",
      website: "https://hideoutchicago.com",
      latitude: 41.9132,
      longitude: -87.6622,
    },
    {
      name: "Lincoln Hall",
      street_address: "2424 N Lincoln Ave",
      city: "Chicago",
      state: "IL",
      zip_code: "60614",
      category: "Bar",
      website: "https://lh-st.com/venues/lincoln-hall",
      latitude: 41.9260,
      longitude: -87.6495,
    },
    {
      name: "Subterranean",
      street_address: "2011 W North Ave",
      city: "Chicago",
      state: "IL",
      zip_code: "60647",
      category: "Music Hall",
      website: "https://subt.net",
      latitude: 41.9106,
      longitude: -87.6775,
    },
    {
      name: "Beat Kitchen",
      street_address: "2100 W Belmont Ave",
      city: "Chicago",
      state: "IL",
      zip_code: "60618",
      category: "Club",
      website: "https://beatkitchen.com",
      latitude: 41.9393,
      longitude: -87.6805,
    },
    {
      name: "Sleeping Village",
      street_address: "3734 W Belmont Ave",
      city: "Chicago",
      state: "IL",
      zip_code: "60618",
      category: "Bar",
      website: "https://sleeping-village.com",
      latitude: 41.9399,
      longitude: -87.7202,
    },
    {
      name: "Thalia Hall",
      street_address: "1807 S Allport St",
      city: "Chicago",
      state: "IL",
      zip_code: "60608",
      category: "Music Hall",
      website: "https://thaliahallchicago.com",
      latitude: 41.8577,
      longitude: -87.6555,
    },
  ]

  manual_venues.each do |attrs|
    venues << Venue.create!(
      name: attrs[:name],
      street_address: attrs[:street_address],
      city: attrs[:city],
      state: attrs[:state],
      zip_code: attrs[:zip_code],
      category: attrs[:category],
      website: attrs[:website],
      latitude: attrs[:latitude],
      longitude: attrs[:longitude],
      owner_id: owners.sample.id,
    )
  end

  allowed_categories = ["Guitar", "Band", "DJ", "Piano"]
  # events
  10.times do
    start_time = Faker::Time.between(from: DateTime.now + 12.hours, to: DateTime.now + 1.day)
    cover = [true, false].sample

    Event.create!(
      category: allowed_categories.sample,
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

  #create followed artists and venues

  User.find_each do |user|
    user_artists = artists.sample(rand(2..4)) # follow 2–4 artists
    user_venues = venues.sample(rand(2..4))  # follow 2–4 venues

    user_artists.each do |artist|
      ArtistFollow.find_or_create_by!(user: user, artist: artist)
    end

    user_venues.each do |venue|
      VenueFollow.find_or_create_by!(user: user, venue: venue)
    end
  end
end
