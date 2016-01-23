$:.unshift File.expand_path('../../lib',__FILE__)
require 'valid_email'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
end
