$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'acts_as_voodoo'

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end
