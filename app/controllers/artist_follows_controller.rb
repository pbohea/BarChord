class ArtistFollowsController < ApplicationController
  before_action :authenticate_user!

  def create
    @artist = Artist.find(params[:artist_id])
    @follow = current_user.artist_follows.create(artist: @artist)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to artist_path(@artist) }
    end
  end

  def destroy
    @follow = current_user.artist_follows.find(params[:id])
    @artist = @follow.artist
    @follow.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to artist_path(@artist) }
    end
  end
end
