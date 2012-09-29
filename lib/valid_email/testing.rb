MxValidator.class_eval do
  class << self
    attr_writer :skip_mx_validation, :valid_domains
    def skip_mx_validation
      @skip_mx_validation || false
    end
    def valid_domains
      @valid_domains || []
    end
  end

  alias_method :validate_each_old, :validate_each
  def validate_each(record, attribute, value)
    return if MxValidator.skip_mx_validation
    m = Mail::Address.new(value)
    unless MxValidator.valid_domains.include? m.domain
      record.errors.add attribute, (options[:message] || I18n.t(:invalid, :scope => "valid_email.validations.email"))
    end
  end

  def self.add_valid_domain(domain)
    domains = MxValidator.valid_domains
    domains << domain
    MxValidator.valid_domains = domains
  end
end
