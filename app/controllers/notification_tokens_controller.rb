class NotificationTokensController < ApplicationController
  before_action :authenticate_user!

  skip_before_action :verify_authenticity_token


  def create
    current_user.notification_tokens.find_or_create_by!(notification_token)
    head :created
  end

  private

  def notification_token
    params.require(:notification_token).permit(:token, :platform)
  end
end
