class ValidateEmail
  class << self
    def valid?(value, user_options={})
      options = { :mx => false, :message => nil }.merge(user_options)

      m = Mail::Address.new(value)
      # We must check that value contains a domain and that value is an email address
      return false unless m.domain && m.address == value

      # Check that domain consists of dot-atom-text elements > 1 and does not
      # contain spaces.
      #
      # In mail 2.6.1, domains are invalid per rfc2822 are parsed when they shouldn't
      # This is to make sure we cover those cases

      return false unless m.domain.match(/^\S+$/)

      domain_dot_elements = m.domain.split(/\./)
      return false unless domain_dot_elements.size > 1 && domain_dot_elements.all?(&:present?)

      # Two dots next to each other or a dot at the beginning or end of the local part are not allowed by RFC2822.
      return false unless m.local.split('.', -1).all?(&:present?)

      # Check if domain has DNS MX record
      if options[:mx]
        require 'valid_email/mx_validator'
        return mx_valid?(value)
      end

      # Check if the domain contains only word chars and dots
      if (m.domain =~ /\A(\w|\.)*\Z/i).nil?
        return false
      end

      true
    rescue Mail::Field::ParseError
      false
    end

    def mx_valid?(value, fallback=false)
      m = Mail::Address.new(value)
      return false unless m.domain

      mx = []
      Resolv::DNS.open do |dns|
        mx.concat dns.getresources(m.domain, Resolv::DNS::Resource::IN::MX)
        mx.concat dns.getresources(m.domain, Resolv::DNS::Resource::IN::A) if fallback
      end

      return mx.any?
    rescue Mail::Field::ParseError
      false
    end

    def mx_valid_with_fallback?(value)
      mx_valid?(value, true)
    end

    def ban_disposable_email?(value)
      m = Mail::Address.new(value)
      m.domain && !BanDisposableEmailValidator.config.include?(m.domain)
    rescue Mail::Field::ParseError
      false
    end
  end
end
