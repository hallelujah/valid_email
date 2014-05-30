require 'active_model'
require 'active_model/validations'
require 'mail'
class BanDisposableEmailValidator < ActiveModel::EachValidator
  # A list of disposable email domains
  def self.config=(options)
    @@config = options
  end

  def validate_each(record, attribute, value)
    begin
      m = Mail::Address.new(value)
      r = !@@config.include?(m.domain) if m.domain
    rescue Exception => e
      r = false
    end
    record.errors.add attribute, (options[:message] || I18n.t(:invalid, :scope => "valid_email.validations.email")) unless r
  end
end
