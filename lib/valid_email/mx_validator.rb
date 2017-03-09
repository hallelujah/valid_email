require 'active_model'
require 'active_model/validations'
require 'resolv'
require 'valid_email/validate_email'
class MxValidator < ActiveModel::EachValidator
  def self.config
    @@config = { timeouts: [] } unless defined? @@config

    @@config
  end

  def validate_each(record,attribute,value)
    r = ValidateEmail.mx_valid?(value)
    record.errors.add attribute, (options[:message] || I18n.t(:invalid, :scope => "valid_email.validations.email")) unless r

    r
  end
end
