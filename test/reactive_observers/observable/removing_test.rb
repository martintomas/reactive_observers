require "test_helper"
require 'reactive_observers/observer/container'
require 'reactive_observers/observable/removing'

module ReactiveObservers
  module Observable
    class RemovingTest < ActiveSupport::TestCase
      class Observer2
        def changed(value, **observer); end
      end

      setup do
        @observed_object = CustomObserver.new
        @observer1 = ReactiveObservers::Observer::Container.new(CustomObserver, Topic,{})
        @observer2 = ReactiveObservers::Observer::Container.new(CustomObserver, Topic, on: [:create, :update])
        @observer3 = ReactiveObservers::Observer::Container.new(CustomObserver, Topic.first,{})
        @observer4 = ReactiveObservers::Observer::Container.new(CustomObserver, Topic.last, on: [:create, :update])
        @observer5 = ReactiveObservers::Observer::Container.new(Observer2, Comment, on: [:create, :update])
        @observer6 = ReactiveObservers::Observer::Container.new(@observed_object, Topic, {})
        @observer7 = ReactiveObservers::Observer::Container.new(@observed_object, Topic,  on: [:create, :update])
        @observer8 = ReactiveObservers::Observer::Container.new(@observed_object, Topic.first, {})
        @observer9 = ReactiveObservers::Observer::Container.new(@observed_object, Topic.last,  on: [:create, :update])
        @observer10 = ReactiveObservers::Observer::Container.new(CustomObserver.new, Comment, on: [:create, :update])
        @observers = [@observer1, @observer2, @observer3, @observer4, @observer5, @observer6, @observer7, @observer8,
                      @observer9, @observer10]
      end

      test '#perform - remove observer for defined klass' do
        result = ReactiveObservers::Observable::Removing.new(@observers, CustomObserver, {}).perform

        assert_equal 6, result.length
        assert result.none?(@observer1)
        assert result.none?(@observer2)
        assert result.none?(@observer3)
        assert result.none?(@observer4)
      end

      test '#perform - remove observer for defined klass and specific record' do
        result = ReactiveObservers::Observable::Removing.new(@observers, CustomObserver, constrain: [Topic.first.id]).perform

        assert_equal 9, result.length
        assert result.none?(@observer3)
      end

      test '#perform - remove observer for defined object' do
        result = ReactiveObservers::Observable::Removing.new(@observers, @observed_object, {}).perform

        assert_equal 6, result.length
        assert result.none?(@observer6)
        assert result.none?(@observer7)
        assert result.none?(@observer8)
        assert result.none?(@observer9)
      end

      test '#perform - remove observer for defined object and specific record' do
        result = ReactiveObservers::Observable::Removing.new(@observers, @observed_object, constrain: [Topic.first.id]).perform

        assert_equal 9, result.length
        assert result.none?(@observer8)
      end

      test '#perform - remove observer for defined klass with additional arguments' do
        result = ReactiveObservers::Observable::Removing.new(@observers.dup, CustomObserver, on: :create).perform
        assert_equal 6, result.length
        assert result.none?(@observer1)
        assert result.none?(@observer2)
        assert result.none?(@observer3)
        assert result.none?(@observer4)

        result = ReactiveObservers::Observable::Removing.new(@observers.dup, CustomObserver, on: :destroy).perform
        assert_equal 8, result.length
        assert result.none?(@observer1)
        assert result.none?(@observer3)

        result = ReactiveObservers::Observable::Removing.new(@observers.dup, CustomObserver, on: :destroy, constrain: [Topic.first.id]).perform
        assert_equal 9, result.length
        assert result.none?(@observer3)
      end

      test '#perform - remove observer for defined object with additional arguments' do
        result = ReactiveObservers::Observable::Removing.new(@observers.dup, @observed_object, on: :create).perform
        assert_equal 6, result.length
        assert result.none?(@observer6)
        assert result.none?(@observer7)
        assert result.none?(@observer8)
        assert result.none?(@observer9)

        result = ReactiveObservers::Observable::Removing.new(@observers.dup, @observed_object, on: :destroy).perform
        assert_equal 8, result.length
        assert result.none?(@observer6)
        assert result.none?(@observer8)

        result = ReactiveObservers::Observable::Removing.new(@observers.dup, @observed_object, on: :destroy, constrain: [Topic.first.id]).perform
        assert_equal 9, result.length
        assert result.none?(@observer8)
      end
    end
  end
end
