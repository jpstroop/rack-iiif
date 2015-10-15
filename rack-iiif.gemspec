#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = 'rack-iiif'
  gem.homepage           = 'http://github.com/no-reply/rack-iiif'
  gem.license            = 'Public Domain' if gem.respond_to?(:license=)
  gem.summary            = 'IIIF support for Rack Servers'
  gem.description        = 'IIIF'

  gem.authors            = ['Tom Johnson', 'Jon Stroop']
  gem.email              = 'iiif-discuss@googlegroups.com'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS CHANGELOG.md README.md UNLICENSE VERSION) +
                           Dir.glob('lib/**/*.rb') + Dir.glob('app/**/*.rb')
  gem.default_executable = gem.executables.first
  gem.require_paths      = %w(lib app)
  gem.has_rdoc           = false

  gem.required_ruby_version      = '>= 2.1.0'
  gem.requirements               = []

  gem.add_runtime_dependency     'rack', '~> 1.6'
  gem.add_runtime_dependency     'sinatra', '~> 1.4'
  gem.add_runtime_dependency     'ruby-vips', '~> 0.3.9'

  gem.add_development_dependency 'rspec',       '~> 3.0'
  gem.add_development_dependency 'rack-test',   '~> 0.6'
  gem.add_development_dependency 'rspec-its',   '~> 1.0'
  gem.add_development_dependency 'yard',        '~> 0.8'

  gem.post_install_message       = nil
end
