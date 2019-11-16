require 'reactive_observers/observable_services/filtering'

module ReactiveObservers
  module ObservableServices
    class Notification
      def initialize(observed_object, observers, action, options)
        @observed_object = observed_object
        @observers = observers
        @action = action
        @options = options
      end

      def perform
        filter_observers.each do |observer|
          next if observer[:only].present? && !observer[:only].call(@observed_object)

          trigger_actions_for observer, Array.wrap(refine_observer_records_for(observer))
        end
      end

      private

      def filter_observers
        @filtered_observers ||= Filtering.new(@observers, @action, @options).perform
      end

      def trigger_actions_for(observer, records)
        records.each do |record|
          Array.wrap(observer_objects_for(observer, record)).each do |observer_object|
            trigger_observer_action_for observer, observer_object, record
          end
        end
      end

      def trigger_observer_action_for(observer, observer_object, record)
        trigger = build_proc_for observer[:trigger], observer_object
        return trigger.call if observer_object.is_a? record.class

        trigger.call record
      end

      def refine_observer_records_for(observer)
        return @observed_object if observer[:refine].blank?

        observer[:refine].call @observed_object
      end

      def observer_objects_for(observer, record)
        return observer[:object] if observer[:object].present?
        return build_proc_for(observer[:initialize], observer[:klass]).call record if observer[:initialize].present?

        observer[:klass].new
      end

      def build_proc_for(variable, object)
        return variable unless variable.is_a? Symbol

        object.method variable
      end
    end
  end
end
