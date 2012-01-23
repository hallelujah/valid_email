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
    record.errors.add attribute, (options[:message] || I18n.t(:invalid, :scope => "valid_email.validations.email")) unless r
    r
  end
end
