class ArtistsController < ApplicationController
  before_action :set_artist, only: [:show, :dashboard, :venue_requests] # Add venue_requests here

  # def search
  #   query = params[:query].to_s.strip.downcase
  #   artists = Artist.where("LOWER(username) LIKE ?", "%#{query}%")
  #                   .select(:id, :username)
  #                   .limit(5)

  #   render json: artists
  # end

  def search
    query = params[:query].to_s.strip.downcase
    artists = Artist.where("LOWER(username) LIKE ?", "%#{query}%")
                    .limit(5)

    # Build the response with proper image URLs
    artists_json = artists.map do |artist|
      {
        id: artist.id,
        username: artist.username,
        bio: artist.bio || "",
        image: artist.image.attached? ? url_for(artist.image) : nil,
      }
    end

    render json: artists_json
  end

  def show
    @artist = Artist.find(params[:id])
    @upcoming_events = @artist.events.upcoming
    @past_events = @artist.events.past.limit(10)
  end

  def events
    @artist = Artist.find(params[:id])
    @upcoming_events = @artist.events.upcoming
    @past_events = @artist.events.past.limit(10)
  end

  def dashboard
    @artist = current_artist
    @upcoming_events = @artist.upcoming_events
    @past_events = @artist.past_events
  end

  def promo_flyer
    require "rqrcode"

    @artist = Artist.find(params[:id])
    @qr_code = RQRCode::QRCode.new("https://apps.apple.com/us/app/your-app-placeholder/id123456789")
  rescue ActiveRecord::RecordNotFound
    @artist = nil
    @qr_code = nil
  rescue StandardError => e
    Rails.logger.error "QR Code generation error: #{e.message}"
    @qr_code = nil
    render layout: "print"
  end

  def promo_flyer_print
    require "rqrcode"

    @artist = Artist.find(params[:id])
    @qr_code = RQRCode::QRCode.new("https://apps.apple.com/us/app/your-app-placeholder/id123456789")
    render layout: "print"
  rescue ActiveRecord::RecordNotFound
    @artist = nil
    @qr_code = nil
  rescue StandardError => e
    Rails.logger.error "QR Code generation error: #{e.message}"
    @qr_code = nil
  end

  def venue_requests
    @venue_requests = VenueRequest.where(requester_type: "artist", requester_id: @artist.id)
                                  .order(created_at: :desc)
  end

  def landing
    @artist = Artist.find(params[:id])
    # Add any authorization check if needed
    redirect_to root_path unless @artist == current_artist
  end

  private

  def set_artist
    @artist = Artist.find(params[:id])
  end
end
