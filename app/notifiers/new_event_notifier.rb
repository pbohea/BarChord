class NewEventNotifier < ApplicationNotifier
  required_param :event
  deliver_by :ios do |config|
    config.device_tokens = -> {
      recipient.notification_tokens.where(platform: :ios).pluck(:token)
    }
    config.format = ->(apn) {
      apn.alert = "New event from one of your favorite artists"
      apn.custom_payload = {
        path: event_path(params[:event])
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
