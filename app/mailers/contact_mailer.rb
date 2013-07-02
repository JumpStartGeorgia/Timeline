class ContactMailer < ActionMailer::Base
  default :from => ENV['TIMELINE_FROM_EMAIL']
  default :to => ENV['TIMELINE_TO_EMAIL']

  def new_message(message)
    @message = message
    mail(:from => "#{message.name} <#{message.email}>",
			:subject => I18n.t("mailer.subject"))
  end

end
