# frozen_string_literal: true

require File.expand_path('lib/overnight/version', __dir__)

Gem::Specification.new do |s|
  s.name    = 'overnight'
  s.summary = 'Nightscout monitor that sends Pushover notifications'
  s.version = Overnight::VERSION

  s.author  = 'Stuart Webster'
  s.files   = Dir['lib/**/*.rb'] + Dir['bin/*']
  s.homepage = 'https://github.com/swebster/overnight'
  s.license = 'MIT'

  s.required_ruby_version = '>= 3.4.0'

  s.add_dependency 'dotenv', '~> 3.1'
  s.add_dependency 'dry-validation', '~> 1.11'
  s.add_dependency 'json', '~> 2.12'
  s.add_dependency 'jwt', '~> 2.10'
  s.add_dependency 'rainbow', '~> 3.1'
  s.add_dependency 'rufus-scheduler', '~> 3.9'
  s.add_dependency 'typhoeus', '~> 1.4'

  s.add_development_dependency 'minitest', '~> 5.25'
  s.add_development_dependency 'rubocop', '~> 1.75'
  s.add_development_dependency 'ruby-lsp', '~> 0.23'
end
