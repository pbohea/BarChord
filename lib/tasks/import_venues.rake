# lib/tasks/import_venues.rake
# bin/rails venues:import
namespace :venues do
  desc "Import venues from JSON files in db/venue_imports"
  task import: :environment do
    Dir.glob(Rails.root.join("db", "venue_imports", "*.json")).each do |file_path|
      puts "📄 Importing from #{file_path}"
      file = File.read(file_path)
      data = JSON.parse(file)

      data.each do |venue_json|
        # Skip if place_id is already in DB
        next if Venue.exists?(place_id: venue_json["place_id"])

        venue = Venue.new(
          name: venue_json["name"],
          street_address: venue_json["street_address"],
          city: venue_json["city"],
          state: venue_json["state"],
          zip_code: venue_json["zip_code"],
          latitude: venue_json["latitude"],
          longitude: venue_json["longitude"],
          website: venue_json["website"],
          category: venue_json["category"],
          place_id: venue_json["place_id"]
        )

        if venue.save
          puts "✅ Created venue: #{venue.name}"
        else
          puts "❌ Failed to save #{venue.name}: #{venue.errors.full_messages.join(', ')}"
        end
      end
    end
  end
end
