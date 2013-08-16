require 'resque'
require 'rails'

module Delayed     
  class Railtie < Rails::Railtie
    initializer :after_initialize do
      ActiveSupport.on_load(:action_mailer) do
        ActionMailer::Base.send(:extend, DelayedResque::DelayMail)
      end
    end

    rake_tasks do
      load "resque/tasks.rb"
    end
  end
end