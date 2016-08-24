# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'multicfg'
  spec.version       = '0.0.1'
  spec.authors       = ['JJ Buckley']
  spec.email         = ['jjbuckley@gmail.com']

  spec.summary       = 'Load configuration from various places'
  spec.description   = 'Use this in your Ruby programs to load up a hash of '\
                       'options from various files, streams and environment '\
                       'variables.'
  spec.homepage      = 'https://movinga.gitlab.com/multicfg'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
