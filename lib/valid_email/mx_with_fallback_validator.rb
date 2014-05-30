require 'valid_email/mx_validator'
class MxWithFallbackValidator < MxValidator
  def valid_domain?(domain)
    mx = []
    Resolv::DNS.open do |dns|
      mx.concat dns.getresources(domain, Resolv::DNS::Resource::IN::MX)
      mx.concat dns.getresources(domain, Resolv::DNS::Resource::IN::A)
    end
    mx.size > 0
  end
end
