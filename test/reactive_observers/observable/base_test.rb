require "test_helper"
require 'reactive_observers/observable/base'
require 'reactive_observers/observer/container'

module ReactiveObservers
  module Observable
    class BaseTest < ActiveSupport::TestCase
      test '.register_observer' do
        observer = ReactiveObservers::Observer::Container.new(CustomObserver, Topic, {})
        Topic.register_observer observer
        assert_equal 1, Topic.active_observers.length
        assert Topic.active_observers.include?(observer)
      end

      test '.register_observer - do not register same observer twice' do
        observer = ReactiveObservers::Observer::Container.new(CustomObserver, Topic, {})
        Topic.register_observer observer
        Topic.register_observer observer
        assert_equal 1, Topic.active_observers.length
        assert Topic.active_observers.include?(observer)
      end

      test '.remove_observer - remove existent observer' do
        observer = ReactiveObservers::Observer::Container.new(CustomObserver, Topic, {})
        Topic.active_observers = [observer]
        Topic.remove_observer observer.observer
        assert_equal [], Topic.active_observers
      end

      test '.remove_observer - remove nonexistent observer' do
        observer = ReactiveObservers::Observer::Container.new(CustomObserver, Topic, {})
        Topic.active_observers = [observer]
        Topic.remove_observer Object
        assert_equal [observer], Topic.active_observers
      end

      test '#remove_observer - remove existent observer' do
        observer = ReactiveObservers::Observer::Container.new(CustomObserver, Topic.first, {})
        Topic.active_observers = [observer]
        Topic.first.remove_observer observer.observer
        assert_equal [], Topic.active_observers
      end

      test '#remove_observer - remove nonexistent observer' do
        observer = ReactiveObservers::Observer::Container.new(CustomObserver, Topic.first, {})
        Topic.active_observers = [observer]
        Topic.last.remove_observer Observer
        assert_equal [observer], Topic.active_observers
      end

      test '.process_observer_notification - insert' do
        observer = ReactiveObservers::Observer::Container.new(CustomObserver, Topic.first, {})
        verify_notification_call_for!(observer, :create, {}) do
          Topic.process_observer_notification id: Topic.first.id, action: 'INSERT'
        end
      end

      test '.process_observer_notification - update' do
        diff = { 'first_name' => 'John' }
        observer = ReactiveObservers::Observer::Container.new(CustomObserver, Topic.first, {})
        verify_notification_call_for!(observer, :update, { diff: diff }) do
          Topic.process_observer_notification id: Topic.first.id, action: 'UPDATE', diff: diff
        end
      end

      test '.process_observer_notification - delete' do
        diff = Topic.first.attributes
        observer = ReactiveObservers::Observer::Container.new(CustomObserver, Topic.first, {})
        verify_notification_call_for!(observer, :destroy, {}) do
          Topic.process_observer_notification diff: diff, action: 'DELETE'
        end
      end

      test '.process_observer_notification - unknown action' do
        assert_raise(StandardError) do
          Topic.active_observers = [ReactiveObservers::Observer::Container.new(CustomObserver, Topic, {})]
          Topic.process_observer_notification action: 'WRONG_ACTION'
        end
      end

      test '.after_create - trigger notification' do
        observer = ReactiveObservers::Observer::Container.new(CustomObserver, Topic, {})
        verify_notification_call_for!(observer, :create, {}, ignore_object_check: true) do
          Topic.create! name: 'third'
        end
      end

      test '.after_update - trigger notification' do
        travel_to Time.current do
          observer = ReactiveObservers::Observer::Container.new(CustomObserver, Topic, {})
          verify_notification_call_for!(observer, :update, { diff: { 'name' => 'first', 'updated_at' => Time.current.to_i }}) do
            Topic.first.update! name: 'third'
          end
        end
      end

      test '.after_destroy - trigger notification' do
        observer = ReactiveObservers::Observer::Container.new(CustomObserver, Topic, {})
        verify_notification_call_for!(observer, :destroy, {}) do
          Topic.first.destroy!
        end
      end

      test '#process_observer_hook_notification - ignore when active record is trigger based' do
        Topic.active_observers = [ReactiveObservers::Observer::Container.new(CustomObserver, Topic, {})]
        Comment.active_observers = [ReactiveObservers::Observer::Container.new(CustomObserver, Comment, {})]
        ReactiveObservers.configuration.observed_tables = [:topics]

        assert_nil Topic.first.process_observer_hook_notification :create
        refute_nil Comment.first.process_observer_hook_notification :create
      end

      test '#process_observer_hook_notification - notification is not performed when no active observer exists' do
        Topic.active_observers = [ReactiveObservers::Observer::Container.new(CustomObserver, Topic, {})]

        refute_nil Topic.first.process_observer_hook_notification :create
        assert_nil Comment.first.process_observer_hook_notification :create
      end

      private

      def verify_notification_call_for!(observer, action, data, checked_model: Topic.first, ignore_object_check: false)
        Topic.active_observers = [observer]
        notification_mock = Minitest::Mock.new
        notification_mock.expect :perform, true
        notification_stub = Proc.new do |*args|
          assert_equal checked_model, args[0] unless ignore_object_check
          assert_equal [observer], args[1]
          assert_equal action, args[2]
          args[3][:diff]['updated_at'] = Time.current.to_i if args[3].dig(:diff, 'updated_at').present?
          assert_equal data, args[3]
          notification_mock
        end

        Observable::Notification.stub :new, notification_stub do
          yield
        end

        notification_mock.verify
      end
    end
  end
end
