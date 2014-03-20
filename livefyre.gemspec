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
  gem.name          = "livefyre-mashable"
  gem.require_paths = ["lib"]
  gem.version       = Livefyre::VERSION

  gem.signing_key = File.expand_path('~/.gemcert/cheald@mashable.com-private_key.pem')
  gem.cert_chain  = ['gem-public_cert.pem']

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
  gem.post_install_message = <<-MESSAGE
  !    The 'livefyre' gem has been deprecated and has been replaced by 'livefyre-mashable'.
  !    An official client library from Livefyre will replace this one in mid-April 2014.
  !    See: https://rubygems.org/gems/livefyre-mashable
  !    And: https://github.com/mashable/livefyre
  MESSAGE
end
