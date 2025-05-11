Geocoder.configure(
  lookup: :google,
  api_key: ENV["GMAPS_KEY"],
  timeout: 5,
  units: :mi
)
