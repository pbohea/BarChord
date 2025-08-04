class NotificationTokensController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def create
    Rails.logger.info "🔐 current_user: #{current_user&.id || "nil"}"
    Rails.logger.info "🔐 session: #{session.to_hash}"
    Rails.logger.info "🔐 request.cookies: #{request.cookies.inspect}"
    current_user.notification_tokens.find_or_create_by!(notification_token)
    head :created
  end

  private

  def notification_token
    params.require(:notification_token).permit(:token, :platform)
  end
end
