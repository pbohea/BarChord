class Admin::VenueRequestsController < ApplicationController
  before_action :authorize_admin!
  before_action :set_venue_request, only: [:approve, :reject, :update_coordinates]

  def index
    @venue_requests = VenueRequest.order(created_at: :desc)

    if params[:status].present? && VenueRequest.statuses.key?(params[:status])
      @venue_requests = @venue_requests.where(status: params[:status])
    end

    if params[:type].present?
      @venue_requests = @venue_requests.where(request_type: params[:type])
    end

    render template: "admin/index"
  end

  def approve
    venue = @venue_request.approve_and_create_venue!

    if venue
      redirect_to admin_venue_requests_path, notice: "Venue request approved and venue created successfully!"
    else
      redirect_to admin_venue_requests_path, alert: "Failed to approve venue request. Please try again."
    end
  end

  def reject
    notes = params[:notes] || "Request rejected by admin"

    if @venue_request.update(status: :rejected, notes: notes)
      redirect_to admin_venue_requests_path, notice: "Venue request rejected."
    else
      redirect_to admin_venue_requests_path, alert: "Failed to reject venue request."
    end
  end

  def update_coordinates
    # For existing venue claims, we need to update coordinates AND approve
    if @venue_request.existing_venue_claim?
      venue = @venue_request.existing_venue

      # Update coordinates if provided
      if params[:latitude].present? && params[:longitude].present?
        venue.latitude = params[:latitude]
        venue.longitude = params[:longitude]
        venue.save!
      end

      # Use the model's approve method which handles ownership assignment
      venue = @venue_request.approve_and_create_venue!

      if venue
        redirect_to admin_venue_requests_path, notice: "Coordinates updated and venue ownership assigned."
      else
        redirect_to admin_venue_requests_path, alert: "Failed to approve venue request."
      end
    else
      # For new venue requests (your existing logic)
      venue = Venue.new(
        name: @venue_request.name,
        street_address: @venue_request.street_address,
        city: @venue_request.city,
        state: @venue_request.state,
        zip_code: @venue_request.zip_code,
        website: @venue_request.website,
        category: @venue_request.category,
        latitude: params[:latitude],
        longitude: params[:longitude],
      )

      if venue.save
        # Assign ownership if it's an ownership claim
        if @venue_request.ownership_claim? && @venue_request.requester_type == "owner"
          venue.update!(owner_id: @venue_request.requester_id)
        end

        @venue_request.update(status: :approved, venue_id: venue.id)
        redirect_to admin_venue_requests_path, notice: "Coordinates updated and venue approved."
      else
        redirect_to admin_venue_requests_path, alert: "Failed to save coordinates."
      end
    end
  end

  private

  def set_venue_request
    @venue_request = VenueRequest.find(params[:id])
  end

  def authorize_admin!
    unless is_admin?
      redirect_to root_path, alert: "You don't have permission to access this page."
    end
  end

  def is_admin?
    user_signed_in? && current_user.email == "pbohea@gmail.com"
  end
end
