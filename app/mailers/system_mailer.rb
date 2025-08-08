class SystemMailer < ApplicationMailer
  def ping(to:)
    mail(to:, subject: "BarChord mail test", body: "If you got this, SMTP via SES works 🎉")
  end
end
