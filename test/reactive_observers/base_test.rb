require "test_helper"
require 'reactive_observers/base'

module ReactiveObservers
  class BaseTest < ActiveSupport::TestCase
    class Observer
      include ReactiveObservers::Base

      def changed(value, **observer); end
    end

    setup do
      Topic.active_observers = []
    end

    teardown do
      Topic.active_observers = []
    end

    test '.observe - register all records' do
      observer = Observer.observe :topics
      assert_equal Observer, observer.observer
      assert_equal Topic, observer.observed
      assert Topic.active_observers.include?(observer)
    end

    test '.observe - register specific record' do
      observer = Observer.observe topics(:first)
      assert_equal Observer, observer.observer
      assert_equal topics(:first), observer.observed
      assert Topic.active_observers.include?(observer)
    end

    test '#observe - register all records' do
      observed_object = Observer.new

      observer = observed_object.observe :topics
      assert_equal observed_object, observer.observer
      assert_equal Topic, observer.observed
      assert Topic.active_observers.include?(observer)
    end

    test '#observe - register specific record' do
      observed_object = Observer.new

      observer = observed_object.observe topics(:first)
      assert_equal observed_object, observer.observer
      assert_equal topics(:first), observer.observed
      assert Topic.active_observers.include?(observer)
    end
  end
end
