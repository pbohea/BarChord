class ApplicationController < ActionController::Base
  # Modern browser enforcement (optional)
  allow_browser versions: :modern
  before_action :store_user_location!, if: :storable_location?

  private

  def storable_location?
    request.get? &&
      is_navigational_format? &&
      !devise_controller? &&
      !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
    store_location_for(:owner, request.fullpath)
    store_location_for(:artist, request.fullpath)
  end

  # Devise helper access
  include Devise::Controllers::Helpers

  # Make Devise-like helpers available for Owner and Artist
  helper_method :owner_signed_in?, :current_owner,
                :artist_signed_in?, :current_artist,
                :user_signed_in?, :current_user

  def current_owner
    @current_owner ||= warden.authenticate(scope: :owner)
  end

  def owner_signed_in?
    current_owner.present?
  end

  def current_artist
    @current_artist ||= warden.authenticate(scope: :artist)
  end

  def artist_signed_in?
    current_artist.present?
  end

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    case resource_class.name
    when "Artist"
      devise_parameter_sanitizer.permit(:sign_up, keys: [:firstname, :lastname, :username, :genre, :type, :website, :image])
      devise_parameter_sanitizer.permit(:account_update, keys: [:firstname, :lastname, :username, :genre, :type, :website, :image])
    when "Owner"
      devise_parameter_sanitizer.permit(:sign_up, keys: [:firstname, :lastname, :username])
      devise_parameter_sanitizer.permit(:account_update, keys: [:firstname, :lastname, :username])
    when "User"
      devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
      devise_parameter_sanitizer.permit(:account_update, keys: [:username])
    end
  end

end
