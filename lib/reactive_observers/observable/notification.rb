# frozen_string_literal: true

require 'reactive_observers/observable/filtering'

module ReactiveObservers
  module Observable
    class Notification
      def initialize(observed_object, observers, action, options)
        @observed_object = observed_object
        @observers = observers
        @action = action
        @options = options
      end

      def perform
        filter_observers.each do |observer|
          process observer, @observed_object
          if @action == :update && observer.trigger_with_previous_values
            process observer, @observed_object.clone.assign_attributes(@options[:diff])
          end
        end
      end

      private

      def filter_observers
        @filtered_observers ||= Filtering.new(@observed_object.id, @observers, @action, @options).perform
      end

      def process(observer, observed_object)
        return if observer.only.present? && !observer.only.call(observed_object)

        trigger_actions_for observer, Array.wrap(refine_observer_records_for(observer, observed_object))
      end

      def trigger_actions_for(observer, records)
        records.each do |record|
          Array.wrap(observer_objects_for(observer, record)).each do |observer_object|
            observer_object = observer_simplification?(observer, observer_object, record) ? record : observer_object
            trigger_observer_action_for observer, observer_object, record
          end
        end
      end

      def trigger_observer_action_for(observer, observer_object, record)
        trigger = build_proc_for observer.trigger, observer_object
        return trigger.call observer.to_h if observer_object == record

        trigger.call record, observer.to_h
      end

      def refine_observer_records_for(observer, observed_object)
        return observed_object if observer.refine.blank?

        observer.refine.call observed_object
      end

      def observer_objects_for(observer, record)
        return observer_objects_from_klass observer, record if observer.klass_observer?
        return build_proc_for(observer.notify, observer.observer).call(observer.observer, record) if observer.notify.present?

        observer.observer
      end

      def observer_objects_from_klass(observer, record)
        return build_proc_for(observer.notify, observer.observer).call(record) if observer.notify.present?

        observer.observer.new
      end

      def build_proc_for(variable, object)
        return variable unless variable.is_a? Symbol

        object.method variable
      end

      def observer_simplification?(observer, record, observer_object)
        (observer_object == record) || (observer.klass_observer? && observer_object.is_a?(record.class))
      end
    end
  end
end
