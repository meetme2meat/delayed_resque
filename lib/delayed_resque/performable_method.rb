require 'active_record'

module DelayedResque
  class PerformableMethod < Struct.new(:object, :method, :args)
    CLASS_STRING_FORMAT = /^CLASS\:([A-Z][\w\:]+)$/
    AR_STRING_FORMAT = /^AR\:([A-Z][\w\:]+)\:(\d+)$/

    def initialize(object, method, options, args)
      raise NoMethodError, "undefined method `#{method}' for #{object.inspect}" unless object.respond_to?(method,true)

      @object = dump(object)
      @method = method.to_sym
      @options = options
      @args = args.map { |a| dump(a) }
    end

    def display_name
      case self.object
      when CLASS_STRING_FORMAT then "#{$1}.#{method}"
      when AR_STRING_FORMAT then "#{$1}##{method}"
      else "Unknown##{method}"
      end
    end

    def self.queue
      "default"
    end
    
    def self.perform(options)
      object = options["obj"]
      method = options["method"] 
      args = options["args"] 
      self.load(object).send(method, *args.map{|a| self.load(a)})
    rescue ActiveRecord::RecordNotFound
      Rails.logger.warn("PerformableMethod: failed to find record for #{object.inspect}")
      # We cannot do anything about objects which were deleted in the meantime
      true
    end

    def store
      {"obj" => @object, "method" => @method, "args" => @args}.merge(@options[:params] || {})
    end

    private

    def self.load(arg)
      case arg
      when CLASS_STRING_FORMAT then $1.constantize
      when AR_STRING_FORMAT then $1.constantize.find($2)
      when Hash then ::HashWithIndifferentAccess.new(arg)
      else arg
      end
    end

    def dump(arg)
      case arg
      when Class, Module then class_to_string(arg)
      when ActiveRecord::Base then ar_to_string(arg)
      else arg
      end
    end

    def ar_to_string(obj)
      "AR:#{obj.class}:#{obj.id}"
    end

    def class_to_string(obj)
      "CLASS:#{obj.name}"
    end
  end
end
