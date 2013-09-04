require 'active_model'
require 'active_model/validations'
require 'mail'
require 'resolv'
class MxValidator < ActiveModel::EachValidator
  def validate_each(record,attribute,value)
    m = Mail::Address.new(value)
    mx = []
    Resolv::DNS.open do |dns|
      mx.concat dns.getresources(m.domain, Resolv::DNS::Resource::IN::MX)
    end
    r = mx.size > 0
    if !r
      # For some reason I don't understand, options is
      # frozen, but I can still modify it
      options[:message] ||= I18n.t(:invalid, :scope => "valid_email.validations.email")
      record.errors.add attribute, :invalid, options
    end
    r
  end
end
