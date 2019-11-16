require 'active_support/concern'

module ReactiveObservers
  module Observe
    extend ActiveSupport::Concern

    included do; end

    class_methods do
      def observe(active_record_name, refine: nil, trigger: nil, initialize: nil, **options)
        klass = active_record_name.classify.constantize
        validate_observe_trigger! klass, trigger
        validate_observe_initialization! klass, initialize
        klass.register_klass_observer options.merge(klass: self, refine: refine, trigger: trigger, initialize: initialize)
      end

      def validate_observe_trigger!(klass, trigger)
        return unless trigger.is_a?(Symbol) && !klass.method_defined?(trigger)

        raise ArgumentError, "Class #{klass.name} is missing required observed method #{trigger}"
      end

      def validate_observe_initialization!(klass, initialize)
        return unless initialize.blank? && klass.method(:new).arity.positive?

        raise ArgumentError, "Initialize parameter is required for observer class #{klass.name} which has complex initialization"
      end
    end
  end
end
