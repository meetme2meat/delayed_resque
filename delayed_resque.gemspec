$:.push File.expand_path("../lib", __FILE__)
require "delayed_resque/version"
Gem::Specification.new do |s|
  s.name = "delayed_resque"
  s.version = DelayedResque::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Viren Negi"]
  s.email = ["meetme2meat@gmail.com"]
  s.homepage = "http://github.com/meetme2meat/delayed_resque"
  s.summary = %q{Delayed Job Syntax mapped over Resque}
  s.description = %q{Gem design to wrap Delayed Job nicety syntax under Resque}

  s.licenses = ["MIT"]
  s.files = Dir["lib/**/*" "README.md", "MIT-LICENSE"]
  s.require_paths = ["lib"]
  s.test_files = Dir.glob('spec/**/*')

  s.add_dependency 'rails'
  s.add_dependency 'resque'
  s.add_dependency 'resque-scheduler'
  
  s.add_development_dependency "rspec"
end
