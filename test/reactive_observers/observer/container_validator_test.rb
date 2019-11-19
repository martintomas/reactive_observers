require "test_helper"
require 'reactive_observers/observer/container'
require 'reactive_observers/observer/container_validator'

module ReactiveObservers
  module Observer
    class ContainerValidatorTest < ActiveSupport::TestCase
      class ComplexNewObserver
        def initialize(value1, value2); end
        def changed; end
      end
      class Observer
        def changed; end
      end

      test '#run_validations! - proper observer' do
        observer = ReactiveObservers::Observer::Container.new(Observer, Topic.first, {})
        assert ReactiveObservers::Observer::ContainerValidator.new(observer).run_validations!

        observer = ReactiveObservers::Observer::Container.new(Observer, Topic, {})
        assert ReactiveObservers::Observer::ContainerValidator.new(observer).run_validations!
      end

      test '#run_validations! - missing trigger method' do
        exception = assert_raise(ArgumentError) do
          observer = ReactiveObservers::Observer::Container.new(Observer, Topic.first, trigger: :update)
          ReactiveObservers::Observer::ContainerValidator.new(observer).run_validations!
        end
        assert_equal "Class ReactiveObservers::Observer::ContainerValidatorTest::Observer is missing required observed method update",
                     exception.message
      end

      test '#run_validations! - missing notify method' do
        exception = assert_raise(ArgumentError) do
          observer = ReactiveObservers::Observer::Container.new(ComplexNewObserver, Topic.first, {})
          ReactiveObservers::Observer::ContainerValidator.new(observer).run_validations!
        end
        assert_equal "Notify parameter is required for observer class ReactiveObservers::Observer::ContainerValidatorTest::ComplexNewObserver which has complex initialization",
                     exception.message
      end

      test '#run_validations! - not active record is observed' do
        exception = assert_raise(ArgumentError) do
          observer = ReactiveObservers::Observer::Container.new(Observer, Observer.new, {})
          ReactiveObservers::Observer::ContainerValidator.new(observer).run_validations!
        end
        assert_equal "Class ReactiveObservers::Observer::ContainerValidatorTest::Observer is not Active Record class",
                     exception.message

        exception = assert_raise(ArgumentError) do
          observer = ReactiveObservers::Observer::Container.new(Observer, Observer, {})
          ReactiveObservers::Observer::ContainerValidator.new(observer).run_validations!
        end
        assert_equal "Class ReactiveObservers::Observer::ContainerValidatorTest::Observer is not Active Record class",
                     exception.message
      end
    end
  end
end
