require 'pry'
require 'timecop'
require 'uri'

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'acts_as_voodoo'

RSpec.configure do |config|
  # Use color in STDOUT
  config.color_enabled = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  config.formatter = :documentation # :progress, :html, :textmate  
end

def objectize_yaml(name)
   data_yaml_file = File.open(File.dirname(__FILE__) + "/support/yaml/#{name}.yml", "r")
   create_http_data( YAML::load(data_yaml_file) )
end   

def create_http_data(raw_data)
   http_data               = OpenStruct.new
   data                    = raw_data["http_interactions"].first
   http_data.url           = data["request"]["uri"]
   http_data.uri           = URI( data["request"]["uri"] )
   http_data.request_body  = data["request"]["body"]["string"]
   http_data.response_body = data["response"]["body"]["string"]
   http_data
end