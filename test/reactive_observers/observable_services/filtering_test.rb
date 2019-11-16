require "test_helper"
require 'reactive_observers/observable_services/filtering'

module ReactiveObservers
  module ObservableServices
    class FilteringTest < Minitest::Test
      def setup
        @observers = [{ observer_id: 1 },
                      { observer_id: 2, on: [:create, :update], fields: [:first_name, :last_name] },
                      { observer_id: 3, on: [:update], fields: [:last_name] }]
      end

      def test_action_filtering
        filtered_observers = ReactiveObservers::ObservableServices::Filtering.new(@observers, :create, {}).perform

        assert_equal 2, filtered_observers.length
        assert filtered_observers.any? { |observer| observer[:observer_id] == 1 }
        assert filtered_observers.any? { |observer| observer[:observer_id] == 2 }
        assert filtered_observers.none? { |observer| observer[:observer_id] == 3 }
      end

      def test_fields_filtering
        changed_fields = { city: 'Prague', first_name: 'John' }
        filtered_observers = ReactiveObservers::ObservableServices::Filtering.new(@observers, :update, diff: changed_fields).perform

        assert_equal 2, filtered_observers.length
        assert filtered_observers.any? { |observer| observer[:observer_id] == 1 }
        assert filtered_observers.any? { |observer| observer[:observer_id] == 2 }
        assert filtered_observers.none? { |observer| observer[:observer_id] == 3 }
      end
    end
  end
end
