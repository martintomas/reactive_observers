# frozen_string_literal: true

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
        true
      end

      private

      def validate_observe_trigger!
        return unless @observer.trigger.is_a?(Symbol) && !@observer.observer_klass.method_defined?(@observer.trigger)

        raise ArgumentError, "Class #{@observer.observer_klass.name} is missing required observed method #{@observer.trigger}"
      end

      def validate_observe_notification!
        return if @observer.notify.present? || !@observer.klass_observer?

        @observer.observer.new
      rescue ArgumentError
        raise ArgumentError, "Notify parameter is required for observer class #{@observer.observer_klass.name} which has complex initialization"
      end

      def validate_observe_active_record!
        return if (!@observer.klass_observed? && @observer.observed.is_a?(ActiveRecord::Base)) ||
          (@observer.klass_observed? && @observer.observed <= ActiveRecord::Base)

        raise ArgumentError, "Class #{@observer.observed_klass.name} is not Active Record class"
      end
    end
  end
end
