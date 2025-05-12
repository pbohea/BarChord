class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def dashboard
    @user = current_user
    @favorite_artists = @user.followed_artists
    @favorite_venues = @user.followed_venues
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
