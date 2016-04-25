require 'active_model'
require 'active_model/validations'
require 'valid_email/validate_email'
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record,attribute,value)
    return if options[:allow_nil] && value.nil?
    return if options[:allow_blank] && value.blank?

    r = ValidateEmail.valid?(value)
    # Check if domain has DNS MX record
    if r && options[:mx]
      require 'valid_email/mx_validator'
      r = MxValidator.new(:attributes => attributes, message: options[:message]).validate(record)
    elsif r && options[:mx_with_fallback]
      require 'valid_email/mx_with_fallback_validator'
      r = MxWithFallbackValidator.new(:attributes => attributes, message: options[:message]).validate(record)
    elsif r && options[:domain]
      require 'valid_email/domain_validator'
      r = DomainValidator.new(:attributes => attributes, message: options[:message]).validate(record)
    end
    # Check if domain is disposable
    if r && options[:ban_disposable_email]
      require 'valid_email/ban_disposable_email_validator'
      r = BanDisposableEmailValidator.new(:attributes => attributes, message: options[:message]).validate(record)
    end
    unless r
      msg = (options[:message] || I18n.t(:invalid, :scope => "valid_email.validations.email"))
      record.errors.add attribute, (msg % {value: value})
    end
  end
end
