# -*- encoding: utf-8 -*-
require File.expand_path('../lib/chunky_css/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Kristofer Walters"]
  gem.email         = ["kris@wltrs.org"]
  gem.description   = %q{Splits css into chunks by @media}
  gem.summary       = %q{Splits css into chunks by @media}
  gem.homepage      = "https://github.com/kwltrs/chunky_css"

  gem.rubyforge_project = "chunky_css"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "chunky_css"
  gem.require_paths = ["lib"]
  gem.version       = ChunkyCSS::VERSION

  gem.add_development_dependency "rspec"
end
