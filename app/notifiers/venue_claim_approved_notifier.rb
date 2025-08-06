class VenueClaimApprovedNotifier < ApplicationNotifier
  required_param :venue_request
  
  deliver_by :ios do |config|
    config.device_tokens = -> {
      recipient.notification_tokens.where(platform: :iOS).pluck(:token)
    }
    config.format = ->(apn) {
      puts "🚨 Formatting venue claim approved APN payload"
      apn.alert = "Your venue claim has been approved!"
      apn.custom_payload = {
        path: venue_path(params[:venue_request].venue_id),
        venue_id: params[:venue_request].venue_id,
        venue_name: params[:venue_request].name
      }
    }
    credentials = Rails.application.credentials.ios
    config.bundle_identifier = credentials.bundle_identifier
    config.key_id = credentials.key_id
    config.team_id = credentials.team_id
    config.apns_key = credentials.apns_key

    config.development = Rails.env.local?
  end
end
