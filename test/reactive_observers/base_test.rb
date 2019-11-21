require "test_helper"
require 'reactive_observers/base'

module ReactiveObservers
  class BaseTest < ActiveSupport::TestCase
    test '.observe - register all records' do
      observer = CustomObserver.observe :topics
      assert_equal CustomObserver, observer.observer
      assert_equal Topic, observer.observed
      assert Topic.active_observers.include?(observer)
    end

    test '.observe - register specific record' do
      observer = CustomObserver.observe topics(:first)
      assert_equal CustomObserver, observer.observer
      assert_equal topics(:first), observer.observed
      assert Topic.active_observers.include?(observer)
    end

    test '#observe - register all records' do
      observed_object = CustomObserver.new

      observer = observed_object.observe :topics
      assert_equal observed_object, observer.observer
      assert_equal Topic, observer.observed
      assert Topic.active_observers.include?(observer)
    end

    test '#observe - register specific record' do
      observed_object = CustomObserver.new

      observer = observed_object.observe topics(:first)
      assert_equal observed_object, observer.observer
      assert_equal topics(:first), observer.observed
      assert Topic.active_observers.include?(observer)
    end
  end
end
