require "test_helper"
require 'reactive_observers/observer/container'

module ReactiveObservers
  module Observer
    class ContainerTest < ActiveSupport::TestCase
      class Observer
        def self.init(value); end
        def updated; end
      end

      test '#initialize - simple' do
        observer = ReactiveObservers::Observer::Container.new(Comment, :topics, {})

        assert_equal Comment, observer.observer
        assert_equal Topic, observer.observed
        assert_equal Configuration.instance.default_trigger, observer.trigger
        assert_equal [], observer.on
        assert_equal [], observer.fields
        assert_equal [], observer.constrain
        assert_nil observer.only
        assert_nil observer.notify
        assert_nil observer.refine
        assert observer.klass_observer?
        assert observer.klass_observed?
        assert_equal Comment, observer.observer_klass
        assert_equal Topic, observer.observed_klass
      end

      test '#initialize - complex' do
        observer_object = Observer.new
        observer = ReactiveObservers::Observer::Container.new(observer_object, Topic.first, trigger: :updated, notify: :init, on: :create, fields: [:first_name, :last_name],
                                                              only: ->() {}, refine: -> {})

        assert_equal observer_object, observer.observer
        assert_equal Topic.first, observer.observed
        assert_equal :updated, observer.trigger
        assert_equal :init, observer.notify
        assert_equal [:create], observer.on
        assert_equal [:first_name, :last_name], observer.fields
        assert_equal [Topic.first.id], observer.constrain
        refute_nil observer.only
        refute_nil observer.refine
        refute observer.klass_observer?
        refute observer.klass_observed?
        assert_equal Observer, observer.observer_klass
        assert_equal Topic, observer.observed_klass
      end

      test '#compare' do
        comparator = ReactiveObservers::Observer::Container.new(Comment, :topics, {}).compare
        assert_equal ReactiveObservers::Observer::ContainerComparator, comparator.class
      end

      test '#klass_observer?' do
        assert ReactiveObservers::Observer::Container.new(Comment, Topic, {}).klass_observer?
        refute ReactiveObservers::Observer::Container.new(Comment.first, Topic, {}).klass_observer?
      end

      test '#klass_observed?' do
        assert ReactiveObservers::Observer::Container.new(Comment, Topic, {}).klass_observed?
        refute ReactiveObservers::Observer::Container.new(Comment, Topic.first, {}).klass_observed?
      end

      test '#observer_klass' do
        assert_equal Comment, ReactiveObservers::Observer::Container.new(Comment, Topic, {}).observer_klass
        assert_equal Comment, ReactiveObservers::Observer::Container.new(Comment.first, Topic, {}).observer_klass
      end

      test '#observed_klass' do
        assert_equal Topic, ReactiveObservers::Observer::Container.new(Comment, Topic, {}).observed_klass
        assert_equal Topic, ReactiveObservers::Observer::Container.new(Comment, Topic.first, {}).observed_klass
      end
    end
  end
end
