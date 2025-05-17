class Users::RegistrationsController < Devise::RegistrationsController
  # GET /users/sign_up
  def new
    super
  end

  # POST /users
  def create
    super do |user|
      track_user_session(user)
    end
  end

  # PUT /users
  def update
    super
  end

  protected

  def after_sign_up_path_for(resource)
    stored_location_for(resource) || user_dashboard_path(resource)
  end

  def after_update_path_for(resource)
    stored_location_for(resource) || user_dashboard_path(resource)
  end

  private

  def track_user_session(user)
    cookies.permanent.encrypted[:user_id] = user.id
    Current.user = user if defined?(Current)
  end
end
