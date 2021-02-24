$:.unshift File.expand_path('../../lib',__FILE__)
require 'valid_email'

RSpec.configure do |config|
  config.order = :random
  config.profile_examples = 10
  config.raise_errors_for_deprecations!
  Kernel.srand config.seed
end
