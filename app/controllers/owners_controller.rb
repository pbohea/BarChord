class OwnersController < ApplicationController
  before_action :authenticate_owner!
  before_action :set_owner

  def dashboard
  end

  private

  def set_owner
    @owner = Owner.find(params[:id])
  end
end
