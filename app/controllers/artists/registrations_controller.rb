class Artists::RegistrationsController < Devise::RegistrationsController
  # GET /artists/sign_up
  def new
    super
  end

  # POST /artists
  def create
    super do |artist|
      track_artist_session(artist)
    end
  end

  # PUT /artists
  def update
    super
  end

  protected

  def after_sign_up_path_for(resource)
    artist_events_path(resource)
  end

  def after_update_path_for(resource)
    artist_events_path(resource)
  end

  private

  def track_artist_session(artist)
    cookies.permanent.encrypted[:artist_id] = artist.id
    Current.artist = artist if defined?(Current)
  end
end
