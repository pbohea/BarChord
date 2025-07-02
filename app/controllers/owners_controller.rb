class OwnersController < ApplicationController
  before_action :authenticate_owner!
  before_action :set_owner

  def dashboard
    @venues = @owner.venues
  end

  def venue_requests
    @venue_requests = VenueRequest.where(requester_type: "owner", requester_id: @owner.id)
                                  .order(created_at: :desc)
  end

  private

  def set_owner
    @owner = Owner.find(params[:id])
  end
end
