# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'page_cursors/version'

Gem::Specification.new do |spec|
  spec.name          = 'graphql-page_cursors'
  spec.version       = PageCursors::VERSION
  spec.authors       = ['Jon Allured']
  spec.email         = ['jon.allured@gmail.com']

  spec.summary       = 'Add page cursors to your Rails GQL schema'
  spec.description   = 'Add page cursors to your Rails GQL schema'
  spec.homepage      = 'https://github.com/artsy/graphql-page_cursors'
  spec.license       = 'MIT'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'graphql'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
end
