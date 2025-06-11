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
    venue = @venue_request.existing_venue || Venue.new(name: @venue_request.name)

    venue.latitude = params[:latitude]
    venue.longitude = params[:longitude]

    if venue.new_record?
      venue.assign_attributes(
        street_address: @venue_request.street_address,
        city: @venue_request.city,
        state: @venue_request.state,
        zip_code: @venue_request.zip_code,
        website: @venue_request.website,
        category: @venue_request.category,
      )
    end

    if venue.save
      @venue_request.update(status: :approved, venue_id: venue.id)
      redirect_to admin_venue_requests_path, notice: "Coordinates updated and venue approved."
    else
      redirect_to admin_venue_requests_path, alert: "Failed to save coordinates."
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
