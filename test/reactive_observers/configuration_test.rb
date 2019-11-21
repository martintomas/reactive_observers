require "test_helper"
require 'reactive_observers/configuration'

module ReactiveObservers
  class ConfigurationTest < ActiveSupport::TestCase
    test 'default values' do
      assert_equal "%{table_name}_notices", ReactiveObservers.configuration.listening_job_name
      assert_equal [], ReactiveObservers.configuration.observed_tables
      assert_equal :changed, ReactiveObservers.configuration.default_trigger
    end

    test 'default values can be changed' do
      ReactiveObservers.configuration.default_trigger = :test

      assert_equal :test, ReactiveObservers.configuration.default_trigger
    end
  end
end
