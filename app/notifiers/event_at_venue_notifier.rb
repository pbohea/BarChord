class EventAtVenueNotifier < ApplicationNotifier
  required_param :event
  
  deliver_by :ios do |config|
    config.device_tokens = -> {
      recipient.notification_tokens.where(platform: :iOS).pluck(:token)
    }
    config.format = ->(apn) {
      puts "🚨 Formatting event at venue APN payload"
      apn.alert = "An event was added at one of your venues"
      apn.custom_payload = {
        path: event_path(params[:event]),
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
