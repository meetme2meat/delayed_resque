require 'active_support'

module DelayedResque
  class DelayProxy < ActiveSupport::BasicObject
    def initialize(payload_class, target, options)
      @payload_class = payload_class
      @target = target
      @options = {:queue => "default"}.update(options)
    end

    def method_missing(method, *args)
      queue = @options[:queue] || @payload_class.queue
      performable = @payload_class.new(@target, method.to_sym, @options, args)
      
      if @options[:unique]
        if @options[:at] or @options[:in]
          ::Resque.remove_delayed(@payload_class, performable.store)
        else
          ::Resque.dequeue(@payload_class, performable.store)
        end
      end
      
      if @options[:at]
        ::Resque.enqueue_at(@options[:at], @payload_class, performable.store) 
      elsif @options[:in]
        ::Resque.enqueue_in(@options[:in], @payload_class, performable.store)
      else
        ::Resque.enqueue_to(queue, @payload_class, performable.store)
      end
    end
  end
  
  
  module MessageSending
    def delay(options = {})
      DelayProxy.new(PerformableMethod, self, options)
    end
    alias __delay__ delay
    
    module ClassMethods
      def handle_asynchronously(method, opts = {})
        aliased_method, punctuation = method.to_s.sub(/([?!=])$/, ''), $1
        with_method, without_method = "#{aliased_method}_with_delay#{punctuation}", "#{aliased_method}_without_delay#{punctuation}"
        define_method(with_method) do |*args|
          curr_opts = opts.clone
          curr_opts.each_key do |key|
            if (val = curr_opts[key]).is_a?(Proc)
              curr_opts[key] = if val.arity == 1
                val.call(self)
              else
                val.call
              end
            end
          end
          delay(curr_opts).__send__(without_method, *args)
        end
        alias_method_chain method, :delay
      end
    end
  end
  
end
