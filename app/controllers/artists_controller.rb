class ArtistsController < ApplicationController
  def search
    artists = Artist.where("username ILIKE ?", "%#{params[:q]}%").limit(10)
    render json: artists.map { |a| { id: a.id, text: a.username } }
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

end
