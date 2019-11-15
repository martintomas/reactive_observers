require 'reactive_observers/observable/filtering'

module ReactiveObservers
  module Observable
    class ProcessNotifications
      def initialize(observed_object, observers, action, options)
        @observed_object = observed_object
        @observers = observers
        @action = action
        @options = options
      end

      def perform
        filter_observers.each do |observer|
          next if observer[:check].present? && !observer[:check].call(@observed_object)

          refined_records = refine_records_for observer
          next trigger_ar_actions_for observer, refined_records if observer[:klass].is_a? ActiveRecord

          trigger_model_actions_for observer, refined_records
        end
      end

      private

      def filter_observers
        @filtered_observers ||= Filtering.new(@observers, @action, @options).perform
      end

      def trigger_ar_actions_for(observer, records)
        records.each do |record|
          record.method(observer[:trigger]).call record, action: @action, diff: @options[:diff]
        end
      end

      def trigger_model_actions_for(observer, records)
        records.each do |record|
          Array.wrap(observing_models_for(observer, record)).each do |observing_object|
            observing_object.method(observer[:trigger]).call record, action: @action, diff: @options[:diff]
          end
        end
      end

      def refine_records_for(observer)
        return @observed_object if observer[:refine].blank?

        Array.wrap observer[:refine].call(@observed_object)
      end

      def observing_models_for(observer, record)
        return observer[:object] if observer[:object].present?
        return observer[:initialize].call record if observer[:initialize].present?

        observer[:klass].new
      end
    end
  end
end
