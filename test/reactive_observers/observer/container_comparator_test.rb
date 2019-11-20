require "test_helper"
require 'reactive_observers/observer/container'
require 'reactive_observers/observer/container_comparator'

module ReactiveObservers
  module Observer
    class ContainerComparatorTest < ActiveSupport::TestCase
      class Observer
        def self.init(value); end

        def changed(value, **observer); end
      end

      test '#partial? - same combinations' do
        observer = ReactiveObservers::Observer::Container.new(Comment, Topic, on: :create, fields: [:first_name, :last_name])
        assert ReactiveObservers::Observer::ContainerComparator.new(observer).partial?(Comment, {})
        assert ReactiveObservers::Observer::ContainerComparator.new(observer).partial?(Comment, on: [:create, :update])
        assert ReactiveObservers::Observer::ContainerComparator.new(observer).partial?(Comment, fields: :first_name)
        assert ReactiveObservers::Observer::ContainerComparator.new(observer).partial?(Comment, on: [:create, :update], fields: :first_name)

        observer = ReactiveObservers::Observer::Container.new(Comment.first, Topic.first, on: :create, fields: [:first_name, :last_name])
        assert ReactiveObservers::Observer::ContainerComparator.new(observer).partial?(Comment.first, constrain: [Topic.first.id])
        assert ReactiveObservers::Observer::ContainerComparator.new(observer).partial?(Comment.first, on: [:create, :update], constrain: [Topic.first.id])

        observer = ReactiveObservers::Observer::Container.new(Comment, Topic, context: :test)
        assert ReactiveObservers::Observer::ContainerComparator.new(observer).partial?(Comment, context: :test)
        assert ReactiveObservers::Observer::ContainerComparator.new(observer).partial?(Comment, {})
    end

      test '#partial? - different combinations' do
        observer = ReactiveObservers::Observer::Container.new(Comment, Topic, on: :create, fields: [:first_name, :last_name])
        refute ReactiveObservers::Observer::ContainerComparator.new(observer).partial?(Comment, context: :test)
        refute ReactiveObservers::Observer::ContainerComparator.new(observer).partial?(Topic, {})
        refute ReactiveObservers::Observer::ContainerComparator.new(observer).partial?(Comment.first, {})
        refute ReactiveObservers::Observer::ContainerComparator.new(observer).partial?(Comment, on: :destroy)
        refute ReactiveObservers::Observer::ContainerComparator.new(observer).partial?(Comment, fields: :city)

        observer = ReactiveObservers::Observer::Container.new(Comment.first, Topic.first, on: :create, fields: [:first_name, :last_name])
        refute ReactiveObservers::Observer::ContainerComparator.new(observer).partial?(Comment, constrain: [Topic.first.id])
        refute ReactiveObservers::Observer::ContainerComparator.new(observer).partial?(Comment.first, constrain: [Topic.last.id])
        refute ReactiveObservers::Observer::ContainerComparator.new(observer).partial?(Comment.first, on: :destroy, constrain: [Topic.first.id])

        observer = ReactiveObservers::Observer::Container.new(Comment, Topic, context: :test)
        refute ReactiveObservers::Observer::ContainerComparator.new(observer).partial?(Comment, context: :test2)
      end

      test '#full? - same combinations' do
        compared_observer = ReactiveObservers::Observer::Container.new(Observer, Topic, trigger: :changed, notify: :init)
        compared_observer1 = ReactiveObservers::Observer::Container.new(Observer, Topic, trigger: :changed, notify: :init)
        assert ReactiveObservers::Observer::ContainerComparator.new(compared_observer).full?(compared_observer1)

        compared_observer = ReactiveObservers::Observer::Container.new(Observer, Topic.first, trigger: :changed, notify: :init)
        compared_observer1 = ReactiveObservers::Observer::Container.new(Observer, Topic.first, trigger: :changed, notify: :init)
        assert ReactiveObservers::Observer::ContainerComparator.new(compared_observer).full?(compared_observer1)
      end

      test '#full? - different combinations' do
        compared_observer = ReactiveObservers::Observer::Container.new(Observer, Topic, {})
        compared_observer1 = ReactiveObservers::Observer::Container.new(Observer, Topic, trigger: :changed, notify: :init)
        refute ReactiveObservers::Observer::ContainerComparator.new(compared_observer).full?(compared_observer1)

        compared_observer = ReactiveObservers::Observer::Container.new(Observer, Topic, trigger: :changed, notify: :init)
        compared_observer1 = ReactiveObservers::Observer::Container.new(Observer, Topic, {})
        refute ReactiveObservers::Observer::ContainerComparator.new(compared_observer).full?(compared_observer1)

        compared_observer = ReactiveObservers::Observer::Container.new(Observer, Topic, trigger: :changed, notify: :init)
        compared_observer1 = ReactiveObservers::Observer::Container.new(Observer.new, Topic, trigger: :changed, notify: :init)
        refute ReactiveObservers::Observer::ContainerComparator.new(compared_observer).full?(compared_observer1)

        compared_observer = ReactiveObservers::Observer::Container.new(Observer, Topic, trigger: :changed, notify: :init)
        compared_observer1 = ReactiveObservers::Observer::Container.new(Observer, Topic.first, trigger: :changed, notify: :init)
        refute ReactiveObservers::Observer::ContainerComparator.new(compared_observer).full?(compared_observer1)

        compared_observer = ReactiveObservers::Observer::Container.new(Observer, Topic.last, trigger: :changed, notify: :init)
        compared_observer1 = ReactiveObservers::Observer::Container.new(Observer, Topic.first, trigger: :changed, notify: :init)
        refute ReactiveObservers::Observer::ContainerComparator.new(compared_observer).full?(compared_observer1)

        compared_observer = ReactiveObservers::Observer::Container.new(Observer, Topic, trigger: ->() {})
        compared_observer1 = ReactiveObservers::Observer::Container.new(Observer, Topic, trigger: ->() {})
        refute ReactiveObservers::Observer::ContainerComparator.new(compared_observer).full?(compared_observer1)
      end
    end
  end
end
