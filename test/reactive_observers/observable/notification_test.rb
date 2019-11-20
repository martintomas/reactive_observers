require "test_helper"
require 'minitest/stub_any_instance'
require 'reactive_observers/observer/container'
require 'reactive_observers/observable/notification'

module ReactiveObservers
  module Observable
    class NotificationTest <  ActiveSupport::TestCase
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

        def changed(**observer)
          raise ObserverNotified
        end

        def changed_with(value, **observer)
          raise ObserverNotified, value
        end
      end

      test '#perform - use only filtering option and filter observer out' do
        turn_off_active_record_check! do |observer|
          observer.only = ->(value) { !value.is_a?(DummyObservable) }
          ReactiveObservers::Observable::Notification.new(DummyObservable.new, [observer], :update, {}).perform
        end
      end

      test '#perform - use only filtering option and do not filter observer out' do
        turn_off_active_record_check! do |observer|
          assert_raises(ObserverNotified) do
            observer.only = ->(value) { value.is_a?(DummyObservable) }
            ReactiveObservers::Observable::Notification.new(DummyObservable.new, [observer], :update, {}).perform
          end
        end
      end

      test '#perform - observer trigger can be proc' do
        turn_off_active_record_check! do |observer|
          assert_raises(ObserverNotified) do
            observer.trigger = -> (*) { raise ObserverNotified }
            ReactiveObservers::Observable::Notification.new(DummyObservable.new, [observer], :update, {}).perform
          end
        end
      end

      test '#perform - trigger can obtain details of observer' do
        context = 'This is observer context'
        turn_off_active_record_check! do |observer|
          exception = assert_raises(ObserverNotified) do
            observer.context = context
            observer.trigger = -> (value, context:, **observer) { raise ObserverNotified, context }
            ReactiveObservers::Observable::Notification.new(DummyObservable.new, [observer], :update, {}).perform
          end
          assert_equal context, exception.message
        end
      end

      test '#perform - observer can be klass' do
        turn_off_active_record_check! do |observer|
          assert_raises(ObserverNotified) do
            observer.observer = DummyObserver
            ReactiveObservers::Observable::Notification.new(DummyObservable.new, [observer], :update, {}).perform
          end
        end
      end

      test '#perform - observer can be klass with special constructor' do
        turn_off_active_record_check! do |observer|
          observer_klass_mock = Minitest::Mock.new
          observer_klass_mock.expect :new, DummyObserver.new, [DummyObservable]

          assert_raises(ObserverNotified) do
            observer.observer = DummyObserver
            observer.notify = ->(value) { observer_klass_mock.new(value) }
            ReactiveObservers::Observable::Notification.new(DummyObservable.new, [observer], :update, {}).perform
          end

          observer_klass_mock.verify
        end
      end

      test '#perform - observer can be klass with special constructor which returns array' do
        turn_off_active_record_check! do |observer|
          observer_klass_mock = Minitest::Mock.new
          observer_klass_mock.expect :new, [DummyObserver.new], [DummyObservable]

          assert_raises(ObserverNotified) do
            observer.observer = DummyObserver
            observer.notify = ->(value) { observer_klass_mock.new(value) }
            ReactiveObservers::Observable::Notification.new(DummyObservable.new, [observer], :update, {}).perform
          end

          observer_klass_mock.verify
        end
      end

      test '#perform - observer object can use notify field to specify notified objects' do
        turn_off_active_record_check! do |observer|
          observer_klass_mock = Minitest::Mock.new
          observer_klass_mock.expect :new, [DummyObserver.new], [DummyObserver, DummyObservable]

          assert_raises(ObserverNotified) do
            observer.notify = ->(observer, value) { observer_klass_mock.new(observer, value) }
            ReactiveObservers::Observable::Notification.new(DummyObservable.new, [observer], :update, {}).perform
          end

          observer_klass_mock.verify
        end
      end

      test '#perform - notify param can be symbol' do
        turn_off_active_record_check! do |observer|
          assert_raises(ObserverNotified) do
            observer.observer = DummyObserver
            observer.notify = :initialize_dummy_object
            ReactiveObservers::Observable::Notification.new(DummyObservable.new, [observer], :update, {}).perform
          end
        end
      end

      test '#perform - observable result can be refined' do
        turn_off_active_record_check! do |observer|
          response = 'observed_information'

          exception = assert_raises(ObserverNotified) do
            observer.refine = -> (*) { response }
            ReactiveObservers::Observable::Notification.new(DummyObservable.new, [observer], :update, {}).perform
          end
          assert_equal response, exception.message
        end
      end

      test '#perform - observable result can be refined which can return array' do
        turn_off_active_record_check! do |observer|
          response = 'observed_information'

          exception = assert_raises(ObserverNotified) do
            observer.refine = -> (*) { [response] }
            ReactiveObservers::Observable::Notification.new(DummyObservable.new, [observer], :update, {}).perform
          end
          assert_equal response, exception.message
        end
      end

      test '#perform - observer object is called directly when observer klass and observable object are same' do
        turn_off_active_record_check! do |observer|
          assert_raises(ObserverNotified) do
            observer.observer = DummyObserver
            observer.trigger = :changed
            ReactiveObservers::Observable::Notification.new(DummyObserver.new, [observer], :update, {}).perform
          end
        end
      end

      test '#perform - observer object is called directly when observer and observable objects are same' do
        turn_off_active_record_check! do |observer|
          assert_raises(ObserverNotified) do
            object = DummyObserver.new
            observer.observer = object
            observer.trigger = :changed
            ReactiveObservers::Observable::Notification.new(object, [observer], :update, {}).perform
          end
        end
      end

      test '#perform - observer object is not called directly when objects are different' do
        turn_off_active_record_check! do |observer|
          assert_raises(ObserverNotified) do
            observer.observer = DummyObserver.new
            ReactiveObservers::Observable::Notification.new(DummyObserver.new, [observer], :update, {}).perform
          end
        end
      end

      private

      def turn_off_active_record_check!
        ReactiveObservers::Observer::ContainerValidator.stub_any_instance :validate_observe_active_record!, true do
          observer = ReactiveObservers::Observer::Container.new DummyObserver.new, DummyObservable, trigger: :changed_with
          yield observer
        end
      end
    end
  end
end
