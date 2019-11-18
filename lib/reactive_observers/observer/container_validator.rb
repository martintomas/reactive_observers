module ReactiveObservers
  module Observer
    class ContainerValidator
      def initialize(observer)
        @observer = observer
      end

      def run_validations!
        validate_observe_trigger!
        validate_observe_notification!
        validate_observe_active_record!
      end

      private

      def validate_observe_trigger!
        return unless @observer.trigger.is_a?(Symbol) && !@observer.observer_klass.method_defined?(@observer.trigger)

        raise ArgumentError, "Class #{@observer.observer_klass.name} is missing required observed method #{@observer.trigger}"
      end

      def validate_observe_notification!
        return unless @observer.notify.blank? && @observer.observer_klass.method(:new).arity.positive?

        raise ArgumentError, "Notify parameter is required for observer class #{@observer.observer_klass.name} which has complex initialization"
      end

      def validate_observe_active_record!
        return unless @observer.observed.class.is_a? ActiveRecord

        raise ArgumentError, "Class #{@observer.observed.class.name} is not Active Record class"
      end
    end
  end
end
