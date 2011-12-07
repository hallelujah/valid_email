require 'active_model'
require 'active_model/validations'
require 'mail'
require 'resolv'
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record,attribute,value)
    begin
      m = Mail::Address.new(value)
      # We must check that value contains a domain and that value is an email address
      r = m.domain && m.address == value
      t = m.__send__(:tree)
      # We need to dig into treetop
      # A valid domain must have dot_atom_text elements size > 1
      # user@localhost is excluded
      # treetop must respond to domain
      # We exclude valid email values like <user@localhost.com>
      # Hence we use m.__send__(tree).domain
      r &&= (t.domain.dot_atom_text.elements.size > 1)
      # Check if domain has DNS MX record
      if r && options[:mx]
	mx = []
        Resolv::DNS.open do |dns|
          mx = dns.getresources(m.domain, Resolv::DNS::Resource::IN::MX)
        end
        r &&= (mx.size > 0)
      end
    rescue Exception => e
      r = false
    end
    record.errors.add attribute, (options[:message] || "is invalid") unless r
  end
end
