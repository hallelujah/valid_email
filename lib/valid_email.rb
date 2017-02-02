require 'valid_email/all'
I18n.load_path += Dir.glob(File.expand_path('../../config/locales/**/*',__FILE__))

class ValidEmail
  def self.config= options
    @@config = options
  end

  def self.disposable_email_services
    @@config['disposable_email_services'] || []
  end

  def self.dns_timeout= value
    @@config['dns_timeout'] = value
  end

  def self.dns_timeout
    @@config['dns_timeout'] || 0.5
  end

  def self.dns_timeout_return_value= value
    @@config['dns_timeout_return_value'] = value
  end

  def self.dns_timeout_return_value
    @@config['dns_timeout_return_value'] || true
  end
end

# Load list of disposable email domains
config_yaml = File.expand_path('../../config/valid_email.yml',__FILE__)
ValidEmail.config = YAML.load_file(config_yaml)

BanDisposableEmailValidator.config= ValidEmail.disposable_email_services
