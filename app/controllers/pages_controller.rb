class PagesController < ApplicationController
  def about
  end

  def artists_about
  end

  def owners_about
  end

  #   def menu
  #   # Force no caching for the menu page - this is crucial for iOS
  #   response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate, private'
  #   response.headers['Pragma'] = 'no-cache'
  #   response.headers['Expires'] = '0'
  #   response.headers['Last-Modified'] = Time.current.httpdate
  #   response.headers['Vary'] = 'Accept-Encoding'

  #   # Optional: Add ETag based on authentication state to force refresh
  #   auth_state = "#{user_signed_in?}-#{artist_signed_in?}-#{owner_signed_in?}"
  #   response.headers['ETag'] = Digest::MD5.hexdigest("menu-#{auth_state}-#{Time.current.to_i}")

  #   # Log the current authentication state for debugging
  #   Rails.logger.info "Menu page - User: #{user_signed_in?}, Artist: #{artist_signed_in?}, Owner: #{owner_signed_in?}"
  # end

  def menu
    # Current cache headers...
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate, private"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
    response.headers["Last-Modified"] = Time.current.httpdate
    response.headers["Vary"] = "Accept-Encoding"

    # Add iOS-specific headers
    response.headers["X-Accel-Expires"] = "0"
    response.headers["Surrogate-Control"] = "no-store"

    # Force unique ETag every time
    auth_state = "#{user_signed_in?}-#{artist_signed_in?}-#{owner_signed_in?}"
    response.headers["ETag"] = Digest::MD5.hexdigest("menu-#{auth_state}-#{Time.current.to_f}")

    Rails.logger.info "Menu page - User: #{user_signed_in?}, Artist: #{artist_signed_in?}, Owner: #{owner_signed_in?}"
    Rails.logger.info "Menu page accessed at #{Time.current}"
  end
end
