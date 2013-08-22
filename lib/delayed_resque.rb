require 'resque'
require 'resque_scheduler'
require 'active_support'
require 'delayed_resque/message_sending'
require 'delayed_resque/performable_method'
if defined?(ActionMailer)
  require 'action_mailer/version'
  require 'delayed_resque/performable_mailer' if 3 == ActionMailer::VERSION::MAJOR
end

require 'active_support/core_ext/hash/indifferent_access'
require 'delayed_resque/railtie' if defined?(Rails::Railtie)

# Support delaying class methods.
Object.send(:include, DelayedResque::MessageSending)
Module.send(:include, DelayedResque::MessageSending::ClassMethods)  
