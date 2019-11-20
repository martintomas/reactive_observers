require "test_helper"
require 'reactive_observers/observer/container'
require 'reactive_observers/observable/filtering'

module ReactiveObservers
  module Observable
    class FilteringTest < ActiveSupport::TestCase
      class Observer
        def changed(value, **observer); end
      end

      setup do
        @observer1 = ReactiveObservers::Observer::Container.new(Observer, Topic.first, {})
        @observer2 = ReactiveObservers::Observer::Container.new(Observer, Topic.first, on: [:create, :update], fields: [:first_name, :last_name])
        @observer3 = ReactiveObservers::Observer::Container.new(Observer, Topic.first, on: [:update], fields: [:last_name])
        @observers = [@observer1, @observer2, @observer3]
      end

      test '#perfom - select all fields' do
        filtered_observers = ReactiveObservers::Observable::Filtering.new(Topic.first.id, @observers, :update, diff: { last_name: 'Black' }).perform

        assert_equal 3, filtered_observers.length
        assert filtered_observers.any?(@observer1)
        assert filtered_observers.any?(@observer2)
        assert filtered_observers.any?(@observer3)
      end

      test '#perform - filter based on action' do
        filtered_observers = ReactiveObservers::Observable::Filtering.new(Topic.first.id, @observers, :create, {}).perform

        assert_equal 2, filtered_observers.length
        assert filtered_observers.any?(@observer1)
        assert filtered_observers.any?(@observer2)
        assert filtered_observers.none?(@observer3)
      end

      test '#perform - filter based on fields' do
        changed_fields = { city: 'Prague', first_name: 'John' }
        filtered_observers = ReactiveObservers::Observable::Filtering.new(Topic.first.id, @observers, :update, diff: changed_fields).perform

        assert_equal 2, filtered_observers.length
        assert filtered_observers.any?(@observer1)
        assert filtered_observers.any?(@observer2)
        assert filtered_observers.none?(@observer3)
      end

      test '#perform - filter based on constrain' do
        @observer3.constrain = [Topic.last.id]
        filtered_observers = ReactiveObservers::Observable::Filtering.new(Topic.first.id, @observers, :update, {}).perform

        assert_equal 2, filtered_observers.length
        assert filtered_observers.any?(@observer1)
        assert filtered_observers.any?(@observer2)
        assert filtered_observers.none?(@observer3)
      end
    end
  end
end
