require 'mail'

class ValidateEmail
  class << self
    SPECIAL_CHARS = %w(( ) , : ; < > @ [ ])
    SPECIAL_ESCAPED_CHARS = %w(\  \\ ")
    LOCAL_MAX_LEN = 64
    DOMAIN_REGEX = /\A^([[:alpha:]]{1}|([[:alnum:]][a-zA-Z0-9-]{0,61}[[:alnum:]]))(\.([[:alnum:]][a-zA-Z0-9-]{0,61}[[:alnum:]]))+\z/

    def valid?(value, user_options={})
      options = {
        :mx => false,
        :domain => false,
        :message => nil
      }.merge(user_options)

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
      return false unless domain_dot_elements.size > 1 && !domain_dot_elements.any?(&:empty?)

      # Ensure that the local segment adheres to adheres to RFC-5322
      return false unless valid_local?(m.local)

      # Check if domain has DNS MX record
      if options[:mx]
        return mx_valid?(value)
      end

      if options[:domain]
        return domain_valid?(value)
      end

      true
    rescue Mail::Field::ParseError
      false
    rescue ArgumentError => error
      if error.message == 'bad value for range'
        false
      else
        raise error
      end
    end

    def valid_local?(local)
      return false unless local.length <= LOCAL_MAX_LEN
      # Emails can be validated by segments delineated by '.', referred to as dot atoms.
      # See http://tools.ietf.org/html/rfc5322#section-3.2.3
      local.split('.', -1).all? { |da| valid_dot_atom?(da) }
    end

    def valid_dot_atom?(dot_atom)
      # Leading, trailing, and double '.'s aren't allowed
      return false if dot_atom.empty?
      # A dot atom can be quoted, which allows use of the SPECIAL_CHARS
      if dot_atom[0] == '"' || dot_atom[-1] == '"'
        # A quoted segment must have leading and trailing '"#"'s
        return false if dot_atom[0] != dot_atom[-1]

        # Excluding the bounding quotes, all of the SPECIAL_ESCAPED_CHARS must have a leading '\'
        index = dot_atom.length - 2
        while index > 0
          if SPECIAL_ESCAPED_CHARS.include? dot_atom[index]
            return false if index == 1 || dot_atom[index - 1] != '\\'
            # On an escaped special character, skip an index to ignore the '\' that's doing the escaping
            index -= 1
          end
          index -= 1
        end
      else
        # If we're not in a quoted dot atom then no special characters are allowed.
        return false unless ((SPECIAL_CHARS | SPECIAL_ESCAPED_CHARS) & dot_atom.split('')).empty?
      end
      true
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

    def domain_valid?(value)
      m = Mail::Address.new(value)
      return false unless m.domain

      !(m.domain =~ DOMAIN_REGEX).nil?
    rescue Mail::Field::ParseError
      false
    end

    def ban_disposable_email?(value)
      m = Mail::Address.new(value)
      m.domain && !BanDisposableEmailValidator.config.include?(m.domain)
    rescue Mail::Field::ParseError
      false
    end
  end
end
