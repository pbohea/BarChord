class ArtistsController < ApplicationController
  def search
    query = params[:query].to_s.strip.downcase
    artists = Artist.where("LOWER(username) LIKE ?", "%#{query}%")
                    .select(:id, :username)
                    .limit(5)

    render json: artists
  end

  def show
    @artist = Artist.find(params[:id])
    @upcoming_events = @artist.events.upcoming
  end

  def events
    @artist = Artist.find(params[:id])
    @upcoming_events = @artist.events.upcoming
  end

  def dashboard
    @artist = current_artist
    @upcoming_events = @artist.upcoming_events
    @past_events = @artist.past_events
  end

  def promo_flyer
    @artist = Artist.find(params[:id])
    render layout: 'print'
  end
end
