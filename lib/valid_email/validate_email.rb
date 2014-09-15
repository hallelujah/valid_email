class ValidateEmail
  
  class << self

    def valid?(value, user_options={})
      options = { :mx => false, :message => nil }.merge!(user_options)
      r       = false
      begin
        parser = EmailAddressParser.new
        t = parser.parse(value)

        r = t.domain && (t.text_value == value)

        case t.domain.dot_atom_text.elements.size
        when 0, 1
          r &&= false
        when 2
          r &&= t.domain.dot_atom_text.elements[-1].empty?
        else
          r &&= true
        end
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

    def mx_valid?(value, fallback=false)
      r = false
      begin
        m = Mail::Address.new(value)
        if m.domain
          mx = []
          Resolv::DNS.open do |dns|
            mx.concat dns.getresources(m.domain, Resolv::DNS::Resource::IN::MX)
            mx.concat dns.getresources(m.domain, Resolv::DNS::Resource::IN::A) if fallback
          end
          r = mx.size > 0
        end
      rescue Exception =>e
        r = false
      end
      r
    end

    def mx_valid_with_fallback?(value)
      mx_valid?(value, true)
    end

    def ban_disposable_email?(value)
      r = false
      begin
        m = Mail::Address.new(value)
        r = !BanDisposableEmailValidator.config.include?(m.domain) if m.domain
      rescue Exception => e
        r = false
      end
      
      r
    end

  end

end
