class NotificationTokensController < ApplicationController
  before_action :authenticate_notifiable!
  skip_before_action :verify_authenticity_token

  def create
    @token = NotificationToken.find_or_initialize_by(
      token: token_params[:token],
      notifiable: @notifiable
    )
    @token.platform = token_params[:platform]
    @token.save!
    head :ok
  end

  private

  def token_params
    params.require(:notification_token).permit(:token, :platform)
  end

  def authenticate_notifiable!
    @notifiable = current_user || current_artist # || current_owner

    unless @notifiable
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
