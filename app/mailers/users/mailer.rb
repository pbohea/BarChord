# frozen_string_literal: true
class Users::Mailer < Devise::Mailer
  # Use your existing SES settings & layout via ApplicationMailer defaults
  default from: ENV.fetch("MAIL_FROM", "admin@barchord.co"),
          reply_to: ENV.fetch("MAIL_FROM", "admin@barchord.co")
  layout "mailer"  # uses app/views/layouts/mailer.html.erb if present

  # Make sure URL helpers work inside mailer
  include Devise::Controllers::UrlHelpers
  default template_path: "users/mailer" # we'll put templates here

  def reset_password_instructions(record, token, opts = {})
    opts[:subject] ||= "BarChord password reset"
    # Build a full URL explicitly (uses your development default_url_options host)
    @reset_url = edit_user_password_url(reset_password_token: token)
    super
  end
end
