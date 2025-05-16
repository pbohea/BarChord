# class venueFollowsController < ApplicationController

# before_action :authenticate_user!

# def create
#   @venue = venue.find(params[:venue_id])
#   @follow = current_user.venue_follows.create(venue: @venue)

#   respond_to do |format|
#     format.turbo_stream
#     format.html { redirect_to venue_path(@venue) }
#   end
# end

# def destroy
#   @follow = current_user.venue_follows.find(params[:id])
#   @venue = @follow.venue
#   @follow.destroy

#   respond_to do |format|
#     format.turbo_stream
#     format.html { redirect_to venue_path(@venue) }
#   end
# end

class VenueFollowsController < ApplicationController
  before_action :set_venue_for_create, only: [:create]
  before_action :set_venue_for_destroy, only: [:destroy]

  def create
    current_user.venue_follows.create!(venue: @venue)

    respond_to do |format|
      format.turbo_stream  # renders create.turbo_stream.erb
      format.html { redirect_to @venue }
    end
  end

  def destroy
    current_user.venue_follows.find_by(venue: @venue)&.destroy

    respond_to do |format|
      format.turbo_stream  # renders destroy.turbo_stream.erb
      format.html { redirect_to @venue }
    end
  end

  private

  def set_venue_for_create
    @venue = Venue.find(params[:venue_id])
  end

  def set_venue_for_destroy
    follow = VenueFollow.find(params[:id])
    @venue = follow.venue
  end
end
