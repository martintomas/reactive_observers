require "test_helper"
require 'reactive_observers/observable_services/notification'

module ReactiveObservers
  module ObservableServices
    class NotificationTest < Minitest::Test
      class ObserverNotified < StandardError; end
      class DummyObservable
        def id
          1
        end
      end

      class DummyObserver
        def self.initialize_dummy_object(*)
          DummyObserver.new
        end

        def id
          2
        end

        def changed
          raise ObserverNotified
        end

        def changed_with(value)
          raise ObserverNotified, value
        end
      end

      def test_only_filtering_option_when_observer_is_filtered_out
        observers = [{ object: DummyObserver.new, trigger: :changed_with, only: ->(value) { !value.is_a?(DummyObservable) }}]
        ReactiveObservers::ObservableServices::Notification.new(DummyObservable.new, observers, :update, {}).perform
      end

      def test_only_filtering_option_when_observer_is_not_filtered_out
        assert_raises(ObserverNotified) do
          observers = [{ object: DummyObserver.new, trigger: :changed_with, only: ->(value) { value.is_a?(DummyObservable) }}]
          ReactiveObservers::ObservableServices::Notification.new(DummyObservable.new, observers, :update, {}).perform
        end
      end

      def test_observer_trigger_can_be_proc
        assert_raises(ObserverNotified) do
          observers = [{ object: DummyObserver.new, trigger: -> (*) { raise ObserverNotified } }]
          ReactiveObservers::ObservableServices::Notification.new(DummyObservable.new, observers, :update, {}).perform
        end
      end

      def test_observer_can_be_klass
        assert_raises(ObserverNotified) do
          observers = [{ klass: DummyObserver, trigger: :changed_with }]
          ReactiveObservers::ObservableServices::Notification.new(DummyObservable.new, observers, :update, {}).perform
        end
      end

      def test_observer_can_be_klass_with_special_constructor
        observer_klass_mock = Minitest::Mock.new
        observer_klass_mock.expect :new, DummyObserver.new, [DummyObservable]

        assert_raises(ObserverNotified) do
          observers = [{ klass: DummyObserver, trigger: :changed_with, notify: ->(value) { observer_klass_mock.new(value) } }]
          ReactiveObservers::ObservableServices::Notification.new(DummyObservable.new, observers, :update, {}).perform
        end

        observer_klass_mock.verify
      end

      def test_observer_can_be_klass_with_special_constructor_which_can_return_array
        observer_klass_mock = Minitest::Mock.new
        observer_klass_mock.expect :new, [DummyObserver.new], [DummyObservable]

        assert_raises(ObserverNotified) do
          observers = [{ klass: DummyObserver, trigger: :changed_with, notify: ->(value) { observer_klass_mock.new(value) } }]
          ReactiveObservers::ObservableServices::Notification.new(DummyObservable.new, observers, :update, {}).perform
        end

        observer_klass_mock.verify
      end

      def test_observer_object_can_use_notify_field_to_specify_notified_objects
        observer_klass_mock = Minitest::Mock.new
        observer_klass_mock.expect :new, [DummyObserver.new], [DummyObserver, DummyObservable]

        assert_raises(ObserverNotified) do
          observers = [{ object: DummyObserver.new, trigger: :changed_with, notify: ->(observer, value) { observer_klass_mock.new(observer, value) } }]
          ReactiveObservers::ObservableServices::Notification.new(DummyObservable.new, observers, :update, {}).perform
        end

        observer_klass_mock.verify
      end

      def test_observer_klass_constructor_can_be_symbol
        assert_raises(ObserverNotified) do
          observers = [{ klass: DummyObserver, trigger: :changed_with, notify: :initialize_dummy_object }]
          ReactiveObservers::ObservableServices::Notification.new(DummyObservable.new, observers, :update, {}).perform
        end
      end

      def test_observable_result_can_be_refined
        response = 'observed_information'

        exception = assert_raises(ObserverNotified) do
          observers = [{ klass: DummyObserver, trigger: :changed_with, refine: -> (*) { response }}]
          ReactiveObservers::ObservableServices::Notification.new(DummyObservable.new, observers, :update, {}).perform
        end
        assert_equal response, exception.message
      end

      def test_observable_result_can_be_refined_which_can_return_array
        response = 'observed_information'

        exception = assert_raises(ObserverNotified) do
          observers = [{ klass: DummyObserver, trigger: :changed_with, refine: -> (*) { [response] }}]
          ReactiveObservers::ObservableServices::Notification.new(DummyObservable.new, observers, :update, {}).perform
        end
        assert_equal response, exception.message
      end

      def test_observer_object_is_called_directly_when_observer_klass_and_observable_object_are_same
        assert_raises(ObserverNotified) do
          observers = [{ klass: DummyObserver, trigger: :changed }]
          ReactiveObservers::ObservableServices::Notification.new(DummyObserver.new, observers, :update, {}).perform
        end
      end

      def test_observer_object_is_called_directly_when_observer_and_observable_objects_are_same
        assert_raises(ObserverNotified) do
          object = DummyObserver.new
          observers = [{ object: object, trigger: :changed }]
          ReactiveObservers::ObservableServices::Notification.new(object, observers, :update, {}).perform
        end
      end

      def test_observer_object_is_not_called_directly_when_objects_are_different
        assert_raises(ObserverNotified) do
          observers = [{ object: DummyObserver.new, trigger: :changed_with }]
          ReactiveObservers::ObservableServices::Notification.new(DummyObserver.new, observers, :update, {}).perform
        end
      end
    end
  end
end
