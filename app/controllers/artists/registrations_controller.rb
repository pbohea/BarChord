class Artists::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
                                                  :firstname, :lastname, :username, :genre, :type, :website, :image,
                                                ])
  end
end
