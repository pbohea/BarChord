# class ApplicationMailer < ActionMailer::Base
#   default from: "from@example.com"
#   layout "mailer"
# end

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "admin@barchord.co")
  layout "mailer"
end
