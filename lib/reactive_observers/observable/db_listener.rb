module DbListener
  extend ActiveSupport::Concern

  included do
    class_attribute :db_observer_services
    self.listener_services = []
  end

  class_methods do
    def register_db_listener(method_name)
      db_observer_services << method_name
    end
  end
end
