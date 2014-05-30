require 'active_model'
require 'active_model/validations'
require 'mail'
require 'resolv'
require 'validate_email'
class MxValidator < ActiveModel::EachValidator
  def validate_each(record,attribute,value)
    r = ValidateEmail.mx_valid?(value)
    record.errors.add attribute, (options[:message] || I18n.t(:invalid, :scope => "valid_email.validations.email")) unless r

    r
  end
end
