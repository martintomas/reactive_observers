require "test_helper"
require 'reactive_observers/observable_services/db_listener'

module ReactiveObservers
  module ObservableServices
    class DbListenerTest < ActiveSupport::TestCase
      class DummyClass
        include ReactiveObservers::ObservableServices::DbListener
      end

      test 'add new method as db listener' do
        assert_empty DummyClass.observer_listener_services

        DummyClass.register_observer_listener :notification_service
        refute_empty DummyClass.observer_listener_services
        assert_equal :notification_service, DummyClass.observer_listener_services.first
      end
    end
  end
end
