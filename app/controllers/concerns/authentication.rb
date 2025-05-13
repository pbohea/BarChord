module Authentication
  extend ActiveSupport::Concern
  included do
    helper_method :current_user, :user_signed_in?
    helper_method :current_owner, :owner_signed_in?
    helper_method :current_artist, :artist_signed_in?
  end

  def sign_in(resource)
    case resource
    when Owner
      Current.owner = resource
      cookies.permanent.encrypted[:owner_id] = resource.id
    when Artist
      Current.artist = resource
      cookies.permanent.encrypted[:artist_id] = resource.id
    when User
      Current.user = resource
      cookies.permanent.encrypted[:user_id] = resource.id
    else
      raise ArgumentError, "Unknown resource type: #{resource.class}"
    end
  end
end
