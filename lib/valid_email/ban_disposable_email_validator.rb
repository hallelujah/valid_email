require 'active_model'
require 'active_model/validations'
require 'valid_email/validate_email'
class BanDisposableEmailValidator < ActiveModel::EachValidator
  # A list of disposable email domains
  def self.config=(options)
    @@config = options
  end

  # Required to use config outside
  def self.config
    @@config = [] unless defined? @@config

    @@config
  end

  def validate_each(record, attribute, value)
    # Check if part of domain is in disposable_email_services yml list
    if options[:partial]
      r = ValidateEmail.ban_partial_disposable_email?(value)
      record.errors.add attribute, (options[:message] ||
        I18n.t(:invalid, :scope => "valid_email.validations.email")) unless r

      r
    else
      r = ValidateEmail.ban_disposable_email?(value)
      record.errors.add attribute, (options[:message] ||
        I18n.t(:invalid, :scope => "valid_email.validations.email")) unless r

      r
    end
  end
end
