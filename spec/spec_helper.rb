$:.unshift File.expand_path('../../lib',__FILE__)
require 'valid_email'

RSpec.configure do |config|
  config.order = :random
  config.raise_errors_for_deprecations!
  Kernel.srand config.seed

  if ENV['CI']
    config.warnings = true
  end
end
