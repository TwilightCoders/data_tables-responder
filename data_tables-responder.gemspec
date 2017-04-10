# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'data_tables/responder/version'

Gem::Specification.new do |spec|
  spec.name          = 'data_tables-responder'
  spec.version       = DataTables::Responder::VERSION
  spec.authors       = ['Dale Stevens']
  spec.email         = ['dale@twilightcoders.net']

  spec.summary       = 'Respond to DataTable requests.'
  spec.homepage      = "https://github.com/TwilightCoders/data_tables-responder"
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  rails_versions = ['>= 4.1', '< 6']

  spec.add_dependency 'active_model_serializers', '~> 0.10.4'
  spec.add_dependency 'railties', rails_versions
  spec.add_dependency 'quick_count', ['>= 0.0.3', '< 0.1.0']

  spec.add_development_dependency 'activerecord', rails_versions
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
