require 'valid_email/mx_validator'
require 'valid_email/validate_email'
class MxWithFallbackValidator < ActiveModel::EachValidator
  def validate_each(record,attribute,value)
    r = ValidateEmail.mx_valid_with_fallback?(value)
    message = Message.new(options[:message]).result
    record.errors.add attribute, (message || I18n.t(:invalid, :scope => "valid_email.validations.email")) unless r

    r
  end
end
