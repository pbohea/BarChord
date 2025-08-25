class VenueRequestsController < ApplicationController
  before_action :authenticate_user_or_artist_or_owner!, only: [:new, :create, :claim, :receipt]

  def new
    @venue_request = VenueRequest.new
  end

  def claim
    # Only allow venue owners to access this
    if owner_signed_in?
      # Proceed to render the claim form
      return
    elsif artist_signed_in?
      redirect_to artist_dashboard_path, alert: "Only venue owners can claim venues."
    elsif user_signed_in?
      redirect_to user_dashboard_path, alert: "Only venue owners can claim venues."
    else
      redirect_to new_owner_session_path, alert: "You must sign in as an owner to claim a venue."
    end
  end

  def create
    @venue_request = VenueRequest.new(venue_request_params)

    if artist_signed_in?
      @venue_request.requester_type = "artist"
      @venue_request.requester_id = current_artist.id
      @venue_request.ownership_claim = false
      @venue_request.request_type = "new_venue"
    elsif owner_signed_in?
      @venue_request.requester_type = "owner"
      @venue_request.requester_id = current_owner.id
      @venue_request.ownership_claim = true

     # Accept either a slug or an id (backwards-compatible)
    slug_or_id = params[:existing_venue_slug].presence || params[:existing_venue_id].presence

    if slug_or_id.present?
      @venue_request.request_type = "existing_venue_claim"

      venue =
        if slug_or_id.to_s =~ /\A\d+\z/
          Venue.find_by(id: slug_or_id.to_i)
        else
          Venue.find_by(slug: slug_or_id)
        end

      if venue
        # Store the numeric id so future lookups work
        @venue_request.existing_venue_id = venue.id

        # Copy venue details (so the request still captures a snapshot)
        @venue_request.name           = venue.name
        @venue_request.street_address = venue.street_address
        @venue_request.city           = venue.city
        @venue_request.state          = venue.state
        @venue_request.zip_code       = venue.zip_code
        @venue_request.website        = venue.website
        @venue_request.category       = venue.category
      else
        # If we can’t resolve it, fall back to new venue request
        @venue_request.request_type = "new_venue"
      end
    else
      @venue_request.request_type = "new_venue"
    end
  else
    redirect_to root_path, alert: "You must be signed in."
    return
  end

  if @venue_request.save
    redirect_to receipt_venue_request_path(@venue_request)
  else
    if params[:existing_venue_slug].present? || params[:existing_venue_id].present?
      render :claim, status: :unprocessable_entity
    else
      render :new, status: :unprocessable_entity
    end
  end
end

  def receipt
    @venue_request = VenueRequest.find(params[:id])

    # Security check - only the requester should see their receipt
    if @venue_request.requester_type == "owner" && current_owner && @venue_request.requester_id != current_owner.id
      redirect_to root_path, alert: "You don't have permission to view this receipt."
      return
    elsif @venue_request.requester_type == "artist" && current_artist && @venue_request.requester_id != current_artist.id
      redirect_to root_path, alert: "You don't have permission to view this receipt."
      return
    elsif !current_owner && !current_artist
      redirect_to root_path, alert: "You must be signed in to view this receipt."
      return
    end

    # Render different templates based on request type AND user type
    if @venue_request.existing_venue_claim?
      render :claim_receipt  # Only owners can claim
    elsif @venue_request.requester_type == "owner"
      render :new_venue_receipt_owner
    elsif @venue_request.requester_type == "artist"
      render :new_venue_receipt_artist
    else
      render :new_venue_receipt_owner  # fallback
    end
  end

  private

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
end
