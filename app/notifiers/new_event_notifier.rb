class NewEventNotifier < ApplicationNotifier
  required_param :event

  deliver_by :ios do |config|
    config.device_tokens = -> {
      NotificationToken.where(
        notifiable_type: 'User',
        notifiable_id: recipient.id,
        platform: 'iOS'
      ).pluck(:token)
    }

    config.format = ->(apn) {
      apn.alert = "New event from one of your favorite artists"
      apn.custom_payload = {
        path: event_path(params[:event])
      }
    }

    # 🛠️ Wrap all credential access in lambdas so they're fetched at runtime
    config.bundle_identifier = -> { Rails.application.credentials.dig(:ios, :bundle_identifier) }
    config.key_id            = -> { Rails.application.credentials.dig(:ios, :key_id) }
    config.team_id           = -> { Rails.application.credentials.dig(:ios, :team_id) }
    config.apns_key          = -> { Rails.application.credentials.dig(:ios, :apns_key) }

    config.delay = false
    config.development = false  # Production push only (for TestFlight)
  end
end
