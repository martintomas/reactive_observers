require 'reactive_observers/observable_services/db_listener'
require 'reactive_observers/observable_services/notification'
require 'reactive_observers/observable_services/removing'

require 'active_support/concern'

module ReactiveObservers
  module Observable
    extend ActiveSupport::Concern
    include ObservableServices::DbListener

    included do
      class_attribute :active_observers
      self.active_observers = []
      register_observer_listener :process_observer_notification

      after_create do
        process_observer_hook_notification :create
      end

      after_update do
        process_observer_hook_notification :update, diff: changed_attributes
      end

      after_destroy do
        process_observer_hook_notification :destroy
      end
    end

    class_methods do
      def register_observer(observer, **options)
        options[:on] = Array.wrap options[:on]
        options[:fields] = Array.wrap options[:fields]
        options[:trigger] ||= Configuration.instance.default_trigger
        observer.is_a?(Class) ? options.merge!(klass: observer) : options.merge!(object: observer)
        return if active_observers.any? { |active_observer| active_observer == options }

        active_observers << options
      end

      def remove_observer(observer, **options)
        observer.is_a?(Class) ? options.merge!(klass: observer) : options.merge!(object: observer)
        ObservableServices::Removing.new(active_observers, options).perform
      end

      def process_observer_notification(data)
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

    def remove_observer(observer, **options)
      self.class.remove_observer observer, options.merge(constrain: [id])
    end

    def process_observer_hook_notification(action, **options)
      return if Configuration.instance.observed_tables.include? self.class.table_name

      process_observer_notifications action, **options
    end

    def process_observer_notifications(action, **options)
      return if self.class.active_observers.blank?

      ObservableServices::Notification.new(self, self.class.active_observers, action, options).perform
    end
  end
end
