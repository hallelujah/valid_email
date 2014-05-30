require 'valid_email/all'
I18n.load_path += Dir.glob(File.expand_path('../../config/locales/**/*',__FILE__))
# Load list of disposable email domains
config = File.expand_path('../../config/valid_email.yml',__FILE__)
BanDisposableEmailValidator.config= YAML.load_file(config)['disposable_email_services'] rescue []
