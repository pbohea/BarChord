class ArtistsController < ApplicationController
  def search
    artists = Artist.where("username ILIKE ?", "%#{params[:q]}%").limit(10)
    render json: artists.map { |a| { id: a.id, text: a.username } }
  end
end
