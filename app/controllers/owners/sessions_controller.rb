class Owners::SessionsController < Devise::SessionsController
  def create
    super do |owner|
      track_owner_session(owner)
    end
  end

  def destroy
    cookies.delete(:owner_id)
    super
  end

  protected

  def after_sign_in_path_for(resource)
    owner_dashboard_path(resource)
  end

  def after_sign_out_path_for(resource_or_scope)
    menu_path
  end

  def respond_to_on_destroy
    # Force a proper HTML redirect instead of turbo_stream
    redirect_to after_sign_out_path_for(resource_name), status: :see_other
  end

  private

  def track_owner_session(owner)
    cookies.permanent.encrypted[:owner_id] = owner.id
    Current.owner = owner if defined?(Current)
  end
end
