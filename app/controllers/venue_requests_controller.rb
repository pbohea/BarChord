class VenueRequestsController < ApplicationController
  before_action :authenticate_user_or_artist_or_owner!, only: [:new, :create]
  before_action :authorize_admin!, only: [:index, :approve, :reject]
  before_action :set_venue_request, only: [:approve, :reject]

  # Admin index
  def index
    @venue_requests = VenueRequest.order(created_at: :desc)
    
    # Filter by status if provided
    if params[:status].present? && VenueRequest.statuses.key?(params[:status])
      @venue_requests = @venue_requests.where(status: params[:status])
    end
  end

  def new
    @venue_request = VenueRequest.new
  end

  def create
    @venue_request = VenueRequest.new(venue_request_params)
    
    if artist_signed_in?
      @venue_request.requester_type = 'artist'
      @venue_request.requester_id = current_artist.id
      @venue_request.ownership_claim = false
      @venue_request.request_type = 'new_venue'
    elsif owner_signed_in?
      @venue_request.requester_type = 'owner' 
      @venue_request.requester_id = current_owner.id
      @venue_request.ownership_claim = true
      
      # Set request type based on whether existing_venue_id is present
      if params[:existing_venue_id].present?
        @venue_request.request_type = 'existing_venue_claim'
        @venue_request.existing_venue_id = params[:existing_venue_id]
        # For existing venues, copy the venue details
        if venue = Venue.find_by(id: params[:existing_venue_id])
          @venue_request.name = venue.name
          @venue_request.street_address = venue.street_address
          @venue_request.city = venue.city
          @venue_request.state = venue.state
          @venue_request.zip_code = venue.zip_code
          @venue_request.website = venue.website
          @venue_request.category = venue.category
        end
      else
        @venue_request.request_type = 'new_venue'
      end
    else
      redirect_to root_path, alert: "You must be signed in."
      return
    end

    if @venue_request.save
      success_message = @venue_request.ownership_claim? ? 
        "Venue and ownership claim submitted!" : 
        "Venue request submitted!"
      
      if artist_signed_in?
        redirect_to artist_dashboard_path(current_artist), notice: success_message
      elsif owner_signed_in?
        redirect_to owner_dashboard_path(current_owner), notice: success_message
      else
        redirect_to root_path, notice: success_message
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Admin approve
  def approve
    venue = @venue_request.approve_and_create_venue!
    
    if venue
      redirect_to venue_requests_path, notice: "Venue request approved and venue created successfully!"
    else
      redirect_to venue_requests_path, alert: "Failed to approve venue request. Please try again."
    end
  end

  # Admin reject
  def reject
    notes = params[:notes] || "Request rejected by admin"
    
    if @venue_request.update(status: :rejected, notes: notes)
      redirect_to venue_requests_path, notice: "Venue request rejected."
    else
      redirect_to venue_requests_path, alert: "Failed to reject venue request."
    end
  end

  private

  def set_venue_request
    @venue_request = VenueRequest.find(params[:id])
  end

  def venue_request_params
    params.require(:venue_request).permit(
      :name, :street_address, :city, :state, :zip_code, 
      :website, :category, :owner_phone, :utility_bill
    )
  end

  def authenticate_user_or_artist_or_owner!
    unless user_signed_in? || artist_signed_in? || owner_signed_in?
      redirect_to root_path, alert: "You must be signed in."
    end
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
