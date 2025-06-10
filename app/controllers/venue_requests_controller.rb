class VenueRequestsController < ApplicationController
  before_action :authenticate_user_or_artist_or_owner!, only: [:new, :create]

  def new
    @venue_request = VenueRequest.new
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

      if params[:existing_venue_id].present?
        @venue_request.request_type = "existing_venue_claim"
        @venue_request.existing_venue_id = params[:existing_venue_id]

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
        @venue_request.request_type = "new_venue"
      end
    else
      redirect_to root_path, alert: "You must be signed in."
      return
    end

    if @venue_request.save
      success_message = @venue_request.ownership_claim? ? "Venue and ownership claim submitted!" : "Venue request submitted!"

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
