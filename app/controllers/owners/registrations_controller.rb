class Owners::RegistrationsController < Devise::RegistrationsController
  # GET /owners/sign_up
  def new
    super
  end

  # POST /owners
  # def create
  #   super do |owner|
  #     track_owner_session(owner)
  #   end
  # end

  def create
    super do |owner|
      if owner.persisted?
        owner.remember_me = true
        owner.save
      end
      track_owner_session(owner)
    end
  end

  # PUT /owners
  def update
    super
  end

  protected

  def after_sign_up_path_for(resource)
    owner_landing_path(resource)
  end

  def after_update_path_for(resource)
    owner_dashboard_path
  end

  private

  def track_owner_session(owner)
    cookies.permanent.encrypted[:owner_id] = owner.id
    Current.owner = owner if defined?(Current)
  end
end
