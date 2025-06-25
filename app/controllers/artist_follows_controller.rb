class ArtistFollowsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_artist_for_create, only: [:create]
  before_action :set_artist_for_destroy, only: [:destroy]

  def create
    current_user.artist_follows.create!(artist: @artist)

    respond_to do |format|
      format.turbo_stream  # renders create.turbo_stream.erb
      format.html { redirect_to @artist }
    end
  end

  def destroy
    current_user.artist_follows.find_by(artist: @artist)&.destroy

    respond_to do |format|
      format.turbo_stream  # renders destroy.turbo_stream.erb
      format.html { redirect_to @artist }
    end
  end

  private

  def set_artist_for_create
    @artist = Artist.find(params[:artist_id])
  end

  def set_artist_for_destroy
    follow = ArtistFollow.find(params[:id])
    @artist = follow.artist
  end
end
