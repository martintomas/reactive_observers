require "test_helper"
require 'reactive_observers/observable_services/notification'

module ReactiveObservers
  module ObservableServices
    class NotificationTest < Minitest::Test
      class DummyClass
        def self.initialize_dummy_object(*)
          DummyClass.new
        end

        def changed
          raise NotImplementedError
        end

        def changed_with(value)
          raise NotImplementedError, value
        end
      end

      def test_only_filtering_option_when_observer_is_filtered_out
        observers = [{ object: DummyClass.new, trigger: :changed, only: ->(value) { !value.is_a?(DummyClass) }}]
        ReactiveObservers::ObservableServices::Notification.new(DummyClass.new, observers, :update, {}).perform
      end

      def test_only_filtering_option_when_observer_is_not_filtered_out
        assert_raises(NotImplementedError) do
          observers = [{ object: DummyClass.new, trigger: :changed, only: ->(value) { value.is_a?(DummyClass) }}]
          ReactiveObservers::ObservableServices::Notification.new(DummyClass.new, observers, :update, {}).perform
        end
      end

      def test_observer_trigger_can_be_proc
        assert_raises(StandardError) do
          observers = [{ object: DummyClass.new, trigger: -> () { raise StandardError } }]
          ReactiveObservers::ObservableServices::Notification.new(DummyClass.new, observers, :update, {}).perform
        end
      end

      def test_observer_can_be_klass
        assert_raises(NotImplementedError) do
          observers = [{ klass: DummyClass, trigger: :changed }]
          ReactiveObservers::ObservableServices::Notification.new(DummyClass.new, observers, :update, {}).perform
        end
      end

      def test_observer_can_be_klass_with_special_constructor
        observer_klass_mock = Minitest::Mock.new
        observer_klass_mock.expect :new, DummyClass.new, [DummyClass]

        assert_raises(NotImplementedError) do
          observers = [{ klass: DummyClass, trigger: :changed, initialize: ->(value) { observer_klass_mock.new(value) } }]
          ReactiveObservers::ObservableServices::Notification.new(DummyClass.new, observers, :update, {}).perform
        end

        observer_klass_mock.verify
      end

      def test_observer_can_be_klass_with_special_constructor_which_can_return_array
        observer_klass_mock = Minitest::Mock.new
        observer_klass_mock.expect :new, [DummyClass.new], [DummyClass]

        assert_raises(NotImplementedError) do
          observers = [{ klass: DummyClass, trigger: :changed, initialize: ->(value) { observer_klass_mock.new(value) } }]
          ReactiveObservers::ObservableServices::Notification.new(DummyClass.new, observers, :update, {}).perform
        end

        observer_klass_mock.verify
      end

      def test_observer_klass_constructor_can_be_symbol
        assert_raises(NotImplementedError) do
          observers = [{ klass: DummyClass, trigger: :changed, initialize: :initialize_dummy_object }]
          ReactiveObservers::ObservableServices::Notification.new(DummyClass.new, observers, :update, {}).perform
        end
      end

      def test_observable_result_can_be_refined
        response = 'observed_information'

        exception = assert_raises(NotImplementedError) do
          observers = [{ klass: DummyClass, trigger: :changed_with, refine: -> (*) { response }}]
          ReactiveObservers::ObservableServices::Notification.new(DummyClass.new, observers, :update, {}).perform
        end
        assert_equal response, exception.message
      end

      def test_observable_result_can_be_refined_which_can_return_array
        response = 'observed_information'

        exception = assert_raises(NotImplementedError) do
          observers = [{ klass: DummyClass, trigger: :changed_with, refine: -> (*) { [response] }}]
          ReactiveObservers::ObservableServices::Notification.new(DummyClass.new, observers, :update, {}).perform
        end
        assert_equal response, exception.message
      end
    end
  end
end
