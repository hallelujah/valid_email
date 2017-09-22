require 'active_model'
require 'active_model/validations'
require 'valid_email/validate_email'

class DomainValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    r = ValidateEmail.domain_valid?(value)
    message = Message.new(options[:message]).result
    record.errors.add attribute, (message || I18n.t(:invalid, :scope => "valid_email.validations.email")) unless r

    r
  end
end

