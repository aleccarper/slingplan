ActionMailer::Base.smtp_settings = {
  address:        'smtp.mandrillapp.com',
  port:           25,
  user_name:      Rails.application.secrets['mandrill']['user_name'],
  password:       Rails.application.secrets['mandrill']['password']
}

# https://github.com/thoughtbot/griddler
Griddler.configure do |config|
  config.processor_class = EmailProcessor
  config.processor_method = :process
  config.reply_delimiter = 'Reply ABOVE THIS LINE'
  config.email_service = :mandrill
end
