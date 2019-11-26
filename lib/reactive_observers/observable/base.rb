# frozen_string_literal: true

require 'reactive_observers/observable/db_listener'
require 'reactive_observers/observable/notification'
require 'reactive_observers/observable/removing'

require 'active_support/concern'

module ReactiveObservers
  module Observable
    # enables class to be observable
    # automatically included to ActiveRecord::Base
    module Base
      extend ActiveSupport::Concern
      include Observable::DbListener

      included do
        class_attribute :active_observers
        self.active_observers = []
        register_observer_listener :process_observer_notification

        after_create do
          process_observer_hook_notification :create
        end

        after_update do
          process_observer_hook_notification :update, diff: previous_changes.each_with_object({}) { |(k, v), r| r[k] = v.first }
        end

        after_destroy do
          process_observer_hook_notification :destroy
        end
      end

      class_methods do
        # register observer to this class
        # @param observer [ReactiveObservers::Observer::Container]
        # @return [Array] active observers
        def register_observer(observer)
          return if active_observers.any? { |active_observer| active_observer.compare.full? observer }

          active_observers << observer
        end

        # remove observer for specific object
        #
        # Topic.remove_observer(ActivityObserver) # remove observer from Topic
        # Topic.remove_observer(observing_service) # removed observer can be also object
        #
        # @param observer [Class, Object] observer that should be removed
        # @param options [Hash] additional options that specifies which observers should be removed
        # @return [Array] still active observers
        def remove_observer(observer, **options)
          Observable::Removing.new(active_observers, observer, options).perform
        end

        # process notification from db trigger
        # @param data [Hash] data obtain from db trigger
        def process_observer_notification(data)
          return if active_observers.blank?

          if data[:action] == 'INSERT'
            find(data[:id]).process_observer_notifications :create
          elsif data[:action] == 'UPDATE'
            find(data[:id]).process_observer_notifications :update, diff: data[:diff]
          elsif data[:action] == 'DELETE'
            new(data[:diff]).process_observer_notifications :destroy
          else
            raise StandardError, "Notification from db returned unknown action: #{data[:action]}"
          end
        end
      end

      # remove observer for specific object
      #
      # Topic.first.remove_observer(ActivityObserver) # remove observer from first topic
      #
      # @param observer [Class, Object] observer that should be removed
      # @param options [Hash] additional options that specifies which observers should be removed
      # @return [Array] still active observers
      def remove_observer(observer, **options)
        self.class.remove_observer observer, options.merge(constrain: [id])
      end

      # process notification from ActiveRecord hooks
      # @param action [Symbol]
      # @param options [Hash]
      def process_observer_hook_notification(action, **options)
        return if ReactiveObservers.configuration.observed_tables.include?(self.class.table_name.to_sym) || self.class.active_observers.blank?

        process_observer_notifications action, **options
      end

      # process observer notification
      # @param action [Symbol]
      # @param options [Hash]
      def process_observer_notifications(action, **options)
        Observable::Notification.new(self, self.class.active_observers, action, options).perform
      end
    end
  end
end
