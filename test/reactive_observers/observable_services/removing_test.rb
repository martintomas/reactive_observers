require "test_helper"
require 'reactive_observers/observable_services/removing'

module ReactiveObservers
  module ObservableServices
    class RemovingTest < Minitest::Test
      class DummyClass; end
      class DummyClass2; end

      def setup
        @observed_object = DummyClass.new
        @observers = [{ observer_id: 1, constrain: [1, 2], klass: DummyClass },
                      { observer_id: 2, on: [:create, :update], constrain: [1, 2], klass: DummyClass },
                      { observer_id: 3, on: [:create, :update], constrain: [1, 2], klass: DummyClass2 },
                      { observer_id: 4, constrain: [1, 2], object: @observed_object },
                      { observer_id: 5, on: [:create, :update], constrain: [1, 2], object: @observed_object },
                      { observer_id: 6, on: [:create, :update], constrain: [1, 2], object: DummyClass.new }]
      end

      def test_remove_observer_for_defined_klass
        result = ReactiveObservers::ObservableServices::Removing.new(@observers, klass: DummyClass).perform

        assert_equal 4, result.length
        assert result.none? { |observer| observer[:observer_id] == 1 }
        assert result.none? { |observer| observer[:observer_id] == 2 }
        assert result.any? { |observer| observer[:observer_id] == 3 }
        assert result.any? { |observer| observer[:observer_id] == 4 }
        assert result.any? { |observer| observer[:observer_id] == 5 }
        assert result.any? { |observer| observer[:observer_id] == 6 }
      end

      def test_remove_observer_for_defined_object
        result = ReactiveObservers::ObservableServices::Removing.new(@observers, object: @observed_object).perform

        assert_equal 4, result.length
        assert result.any? { |observer| observer[:observer_id] == 1 }
        assert result.any? { |observer| observer[:observer_id] == 2 }
        assert result.any? { |observer| observer[:observer_id] == 3 }
        assert result.none? { |observer| observer[:observer_id] == 4 }
        assert result.none? { |observer| observer[:observer_id] == 5 }
        assert result.any? { |observer| observer[:observer_id] == 6 }
      end

      def test_remove_observer_for_defined_klass_with_additional_arguments
        result = ReactiveObservers::ObservableServices::Removing.new(@observers.dup, klass: DummyClass, on: :create, constrain: [1]).perform
        assert_equal 4, result.length
        assert result.none? { |observer| observer[:observer_id] == 1 }
        assert result.none? { |observer| observer[:observer_id] == 2 }

        result = ReactiveObservers::ObservableServices::Removing.new(@observers.dup, klass: DummyClass, on: :destroy, constrain: [1]).perform
        assert_equal 5, result.length
        assert result.none? { |observer| observer[:observer_id] == 1 }

        result = ReactiveObservers::ObservableServices::Removing.new(@observers.dup, klass: DummyClass, on: :create, constrain: [3]).perform
        assert_equal 6, result.length
      end

      def test_remove_observer_for_defined_object_with_additional_arguments
        result = ReactiveObservers::ObservableServices::Removing.new(@observers.dup, object: @observed_object, on: :create, constrain: [1]).perform
        assert_equal 4, result.length
        assert result.none? { |observer| observer[:observer_id] == 4 }
        assert result.none? { |observer| observer[:observer_id] == 5 }

        result = ReactiveObservers::ObservableServices::Removing.new(@observers.dup, object: @observed_object, on: :destroy, constrain: [1]).perform
        assert_equal 5, result.length
        assert result.none? { |observer| observer[:observer_id] == 4 }

        result = ReactiveObservers::ObservableServices::Removing.new(@observers.dup, object: @observed_object, on: :create, constrain: [3]).perform
        assert_equal 6, result.length
      end
    end
  end
end
