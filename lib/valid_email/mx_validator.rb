require 'active_model'
require 'active_model/validations'
require 'mail'
require 'resolv'
class MxValidator < ActiveModel::EachValidator
  def validate_each(record,attribute,value)
    return if options[:allow_nil] && value.nil?
    return if options[:allow_blank] && value.blank?
    begin
      m = Mail::Address.new(value)
      if m.domain
        mx = []
        Resolv::DNS.open do |dns|
          mx.concat dns.getresources(m.domain, Resolv::DNS::Resource::IN::MX)
        end
        r = mx.size > 0
      end
    rescue Mail::Field::ParseError
      #ignore this
    end
    record.errors.add attribute, (options[:message] || I18n.t(:invalid, :scope => "valid_email.validations.mx")) unless r
  end
end
