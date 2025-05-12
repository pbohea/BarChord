  module Authentication
    extend ActiveSupport::Concern
    included do
      helper_method :current_user, :user_signed_in?
      helper_method :current_owner, :owner_signed_in?
      helper_method :current_artist, :artist_signed_in?
    end

    def sign_in(user)
      Current.user = user
      cookies.permanent.encrypted[:user_id] = user.id
    end

    def sign_in(owner)
      Current.owner = owner
      cookies.permanent.encrypted[:owner_id] = owner.id
    end

    def sign_in(artist)
      Current.artist = artist
      cookies.permanent.encrypted[:artist_id] = artist.id
    end
  end
