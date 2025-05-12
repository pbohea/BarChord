class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  include Authentication
  
  allow_browser versions: :modern


  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    if resource_class == Artist
      devise_parameter_sanitizer.permit(:sign_up, keys: [:firstname, :lastname, :username, :genre, :type, :website, :image])
      devise_parameter_sanitizer.permit(:account_update, keys: [:firstname, :lastname, :username, :genre, :type, :website, :image])
    elsif resource_class == Owner
      devise_parameter_sanitizer.permit(:sign_up, keys: [:firstname, :lastname, :username])
      devise_parameter_sanitizer.permit(:account_update, keys: [:firstname, :lastname, :username])
    elsif resource_class == User
      devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
      devise_parameter_sanitizer.permit(:account_update, keys: [:username])
    end
  end
end
