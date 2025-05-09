class Users::RegistrationsController < Devise::RegistrationsController
  protected 

  def after_sign_up_path_for(resource)
    user_dashboard_path(resource)
  end
end
