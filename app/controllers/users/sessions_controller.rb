class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  def create
    super do |user|
      track_user_session(user)
    end
  end

  def destroy
    cookies.delete(:user_id)
    super
  end

  protected

  def after_sign_in_path_for(resource)
    user_dashboard_path(resource)
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  private

  def track_user_session(user)
    cookies.permanent.encrypted[:user_id] = user.id
    Current.user = user if defined?(Current)
  end
end

# GET /resource/sign_in
# def new
#   super
# end

# POST /resource/sign_in
# def create
#   super
# end

# DELETE /resource/sign_out
# def destroy
#   super
# end

# protected

# If you have extra params to permit, append them to the sanitizer.
# def configure_sign_in_params
#   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
# end
