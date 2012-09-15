# -*- encoding: utf-8 -*-
require File.expand_path('../lib/livefyre/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Mashable"]
  gem.email         = ["cheald@mashable.com"]
  gem.description   = %q{Interface library for Livefyre's comment API with Rails helpers}
  gem.summary       = %q{Interface library for Livefyre's comment API with Rails helpers}
  gem.homepage      = "http://github.com/mashable/livefyre"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.name          = "livefyre"
  gem.require_paths = ["lib"]
  gem.version       = Livefyre::VERSION

  gem.add_dependency "faraday"
  gem.add_dependency "jwt"
  gem.add_dependency "ruby-hmac"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "simplecov-rcov"
  gem.add_development_dependency "rails"
  gem.add_development_dependency "resque"
  gem.add_development_dependency "yard"
  gem.add_development_dependency "yard-tomdoc"
  gem.add_development_dependency "redcarpet"
end
