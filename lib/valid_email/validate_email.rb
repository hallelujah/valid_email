class ValidateEmail
  
  class << self

    def valid?(value, user_options={})
      options = { :mx => false, :message => nil }.merge!(user_options)
      r       = false
      begin
        m = Mail::Address.new(value)
        # We must check that value contains a domain and that value is an email address
        r = m.domain && m.address == value
        if r
          # Check that domain consists of dot-atom-text elements > 1
          # In mail 2.6.1, domains are invalid per rfc2822 are parsed when they shouldn't
          # This is to make sure we cover those cases
          domain_dot_elements = m.domain.split(/\./)
          r &&= domain_dot_elements.none?(&:blank?) && domain_dot_elements.size > 1

          # Check if domain has DNS MX record
          if r && options[:mx]
            require 'valid_email/mx_validator'
            r &&= mx_valid?(email)
          end
        end
      rescue Mail::Field::ParseError
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
      rescue Mail::Field::ParseError
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
      rescue Mail::Field::ParseError
        r = false
      end

      r
    end

  end

end
