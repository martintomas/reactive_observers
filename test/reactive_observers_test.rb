require "test_helper"
require 'minitest/stub_any_instance'
require 'reactive_observers/version'
require 'reactive_observers/database_adapters/factory'

class ReactiveObserversTest < ActiveSupport::TestCase
  class ObserverListenersStarted < StandardError; end

  test '.version' do
    refute_nil ReactiveObservers::VERSION
  end

  test '.configure - default set up can be changed' do
    ReactiveObservers.configure { |config| config.default_trigger = :updated }

    assert_equal :updated, ReactiveObservers.configuration.default_trigger
  end

  test '.configure - database listeners are started' do
    ReactiveObservers::DatabaseAdapters::Factory.stub_any_instance :initialize_observer_listeners, ->() { raise ObserverListenersStarted } do
      assert_raise(ObserverListenersStarted) do
        ReactiveObservers.configure
      end
    end
  end
end
