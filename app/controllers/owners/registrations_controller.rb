class Owners::RegistrationsController < Devise::RegistrationsController
  protected 

  def after_sign_up_path_for(resource)
    owner_dashboard_path(resource)
  end
end
