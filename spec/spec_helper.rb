$:.unshift File.expand_path('../../lib',__FILE__)

require 'valid_email'

Dir[File.expand_path("../support/**/*.rb",__FILE__)].each {|f| puts f; require f}

RSpec.configure do |config|
  config.extend Models
  config.include Models
end
