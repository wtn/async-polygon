# frozen_string_literal: true

require_relative 'lib/async/polygon/version'

Gem::Specification.new do |spec|
  spec.name = 'async-polygon'
  spec.version = Async::Polygon::VERSION
  spec.authors = ['William T. Nelson']
  spec.email = ['35801+wtn@users.noreply.github.com']

  spec.summary = 'async client for polygon.io'
  spec.homepage = 'https://github.com/wtn/async-polygon'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines(?\0, chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'async-http', '~> 0.80'
end
