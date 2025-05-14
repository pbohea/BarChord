class Artists::SessionsController < Devise::SessionsController
  def create
    super do |artist|
      track_artist_session(artist)
    end
  end

  def destroy
    cookies.delete(:artist_id)
    super
  end

  protected

  def after_sign_in_path_for(resource)
    artist_events_path # Or replace with your desired artist dashboard path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  private

  def track_artist_session(artist)
    cookies.permanent.encrypted[:artist_id] = artist.id
    Current.artist = artist if defined?(Current)
  end
end
