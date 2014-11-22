class ValidateEmail
  class << self
    attr_accessor :configuration

    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end

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

      # Check if domain has DNS MX record
      if options[:mx]
        require 'valid_email/mx_validator'
        return mx_valid?(value)
      end

      true
    rescue Mail::Field::ParseError
      false
    end

    def mx_valid?(value, fallback=false)
      m = Mail::Address.new(value)
      return false unless m.domain

      mx = if defined?(::Rails) && ValidateEmail.configuration.cache_mx_lookups_for.is_a?(Fixnum)
        cache_key = ['valid_email/mx_valid?', m.domain, fallback]
        Rails.cache.fetch(cache_key, expires_in: ValidateEmail.configuration.cache_mx_lookups_for) do
          domain_mx_records(m.domain, fallback)
        end
      else
        domain_mx_records(m.domain, fallback)
      end

      mx.any?
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

    def domain_mx_records(domain, fallback=false)
      mx = []

      Resolv::DNS.open do |dns|
        mx.concat dns.getresources(domain, Resolv::DNS::Resource::IN::MX)
        mx.concat dns.getresources(domain, Resolv::DNS::Resource::IN::A) if fallback
      end

      return mx
    end
  end

  class Configuration
    attr_accessor :cache_mx_lookups_for

    def initialize
      @cache_mx_lookups_for = nil
    end
  end
end
