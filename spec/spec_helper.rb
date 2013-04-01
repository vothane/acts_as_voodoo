require 'pry'
require 'webmock/rspec'
require 'timecop'
require 'factory_girl'
require 'vcr'

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'acts_as_voodoo'

RSpec.configure do |config|
  # Use color in STDOUT
  config.color_enabled = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  config.formatter = :documentation # :progress, :html, :textmate  

  config.mock_with :rspec  
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/support/vcr_cassettes'
  c.hook_into :webmock
end