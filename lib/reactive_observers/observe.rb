require 'active_support/concern'

module ReactiveObservers
  module Observe
    extend ActiveSupport::Concern

    included do; end

    class_methods do
      def observe(observed, refine: nil, trigger: Configuration.instance.default_trigger, notify: nil, **options)
        active_record_klass = observed.is_a?(Symbol) ? observed.classify.constantize : observed.class
        register_observer_for self, active_record_klass, options.merge(refine: refine, trigger: trigger, notify: notify)
      end

      def register_observer_for(observer, active_record_klass, options)
        validate_observer! active_record_klass, trigger: options[:trigger], notify: options[:notify]
        options.merge! constrain: [observer.id] unless observer.is_a?(Class)
        active_record_klass.register_observer observer, options
      end

      def validate_observer!(klass, trigger: , notify:)
        validate_observe_trigger! trigger
        validate_observe_notification! notify
        validate_observe_active_record! klass
      end

      def validate_observe_trigger!(trigger)
        return unless trigger.is_a?(Symbol) && !self.method_defined?(trigger)

        raise ArgumentError, "Class #{self.name} is missing required observed method #{trigger}"
      end

      def validate_observe_notification!(notify)
        return unless notify.blank? && self.method(:new).arity.positive?

        raise ArgumentError, "Notify parameter is required for observer class #{self.name} which has complex initialization"
      end

      def validate_observe_active_record!(klass)
        return unless klass.is_a? ActiveRecord

        raise ArgumentError, "Class #{klass.name} is not Active Record class"
      end
    end

    def observe(observed, refine: nil, trigger: Configuration.instance.default_trigger, notify: nil, **options)
      active_record_klass = observed.is_a?(Symbol) ? observed.classify.constantize : observed.class
      self.class.register_observer_for self, active_record_klass, options.merge(refine: refine, trigger: trigger, notify: notify)
    end
  end
end
