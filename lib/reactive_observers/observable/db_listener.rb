require 'active_support/concern'

module ReactiveObservers
  module Observable
    module DbListener
      extend ActiveSupport::Concern

      included do
        class_attribute :observer_listener_services
        self.observer_listener_services = []
      end

      class_methods do
        def register_observer_listener(method_name)
          observer_listener_services << method_name
        end
      end
    end
  end
end
