module Models
  class ModelGenerator
    @@models = {}

    def self.build(key, opts = {email: true})
      @@models[key] ||= Class.new do
        include ActiveModel::Validations
        attr_accessor :email
        validates :email, opts
      end
    end
  end

  def simple
    ModelGenerator.build(:simple)
  end

  def mx
    ModelGenerator.build(:mx, mx: true)
  end

  def nil_allowed
    ModelGenerator.build(:allow_nil, email: {allow_nil: true})
  end

  def blank_allowed
    ModelGenerator.build(:allow_blank, email: {allow_blank: true})
  end

  def mx_nil_allowed
    ModelGenerator.build(:mx_nil_allowed, mx: {allow_nil: true})
  end

  def mx_blank_allowed
    ModelGenerator.build(:allow_blank, mx: {allow_blank: true})
  end

end
