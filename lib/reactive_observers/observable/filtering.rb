# frozen_string_literal: true

module ReactiveObservers
  module Observable
    class Filtering
      def initialize(observed_object_id, observers, action, options)
        @observed_object_id = observed_object_id
        @observers = observers
        @action = action
        @options = options
      end

      def perform
        @observers.select do |observer|
          filter_action(observer) && filter_record_constrains(observer) && filter_fields(observer)
        end
      end

      private

      def filter_action(observer)
        observer.on.blank? || observer.on.include?(@action)
      end

      def filter_record_constrains(observer)
        observer.constrain.blank? || observer.constrain.include?(@observed_object_id)
      end

      def filter_fields(observer)
        return true unless @action == :update && @options[:diff].present?

        observer.fields.blank? || (observer.fields & changed_fields).length.positive?
      end

      def changed_fields
        @changed_fields ||= @options[:diff].keys.map &:to_sym
      end
    end
  end
end
