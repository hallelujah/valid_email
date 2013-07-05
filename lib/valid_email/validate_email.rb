module ValidateEmail
  
  def self.valid?(value, user_options={})
    options = { :mx => false, :message => nil }.merge!(user_options)
    r       = false
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
        require 'valid_email/mx_validator'
        r &&= mx_valid?(email)
      end
    rescue Exception => e
      r = false
    end
    r
  end

  def self.mx_valid?(value)
    m = Mail::Address.new(value)
    mx = []
    Resolv::DNS.open do |dns|
      mx.concat dns.getresources(m.domain, Resolv::DNS::Resource::IN::MX)
    end
    r = mx.size > 0
    r
  end

end