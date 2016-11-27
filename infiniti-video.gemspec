# -*- encoding: utf-8 -*-
require File.expand_path('../lib/infiniti_video/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Michael Berkovich"]
  gem.email         = ["theiceberk@gmail.com"]
  gem.description   = %q{Converts videos to a proper format for playback in Infiniti/Nissan}
  gem.summary       = %q{Command line tool for preparing videos for Infiniti/Nissan multimedia system}
  gem.homepage      = 'https://github.com/berk/infiniti-video'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'infiniti-video'
  gem.require_paths = ['lib']
  gem.version       = InfinitiVideo::VERSION
  gem.licenses      = 'MIT'

  gem.add_runtime_dependency 'thor', '~> 0.16.0'
  gem.add_runtime_dependency 'translit', '~> 0.1.5'
end
