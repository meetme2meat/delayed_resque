$:.push File.expand_path("../lib", __FILE__)
require "delayed_resque/version"
Gem::Specification.new do |s|
  s.name = "delayed_resque"
  s.version = DelayedResque::VERSION
  s.authors = ["Viren Negi"]
  s.date = Date.today
  s.email = ["meetme2meat@gmail.com"]
  s.homepage = "http://github.com/meetme2meat/delayed_resque"
  s.summary = %q{Delayed Job Syntax mapped over Resque}
  s.description = %q{Gem design to wrap Delayed Job nicety syntax under Resque}
  s.licenses = ["MIT"]
  s.files = Dir["lib/**/*"]
  s.extra_rdoc_files = ["README.md"]
  s.require_paths = ["lib","MIT-LICENSE"]
  s.test_files = Dir.glob('spec/**/*')
  s.rubygems_version = %q{1.3.6}
  s.add_dependency 'rails', ">= 3.2.0"
  s.add_dependency 'resque',">= 1.19.0"
  s.add_dependency 'resque-scheduler',">= 2.0.0"
  s.add_dependency 'resque_spec'
  s.add_dependency 'sqlite3'
  s.add_dependency 'rspec-rails'
  s.add_development_dependency "rspec"
end
