# -*- encoding: utf-8 -*-
require File.expand_path('../lib/acts_as_voodoo/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Thane Vo"]
  gem.email         = ["vothane@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "acts_as_voodoo"
  gem.require_paths = ["lib"]
  gem.version       = ActsAsVoodoo::VERSION

  gem.add_dependency("activeresource", ["~> 4.0.0.beta1"])
end
