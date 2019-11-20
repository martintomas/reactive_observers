require "test_helper"
require 'reactive_observers/configuration'

module ReactiveObservers
  class ConfigurationTest < Minitest::Test
    def setup
      Configuration.instance.reset!
    end

    def teardown
      Configuration.instance.reset!
    end

    def test_default_values
      configuration = Configuration.instance

      assert_equal "%{table_name}_notices", configuration.listening_job_name
      assert_equal [], configuration.observed_tables
      assert_equal :changed, configuration.default_trigger
    end

    def test_default_values_can_be_changed
      Configuration.instance.default_trigger = :test

      assert_equal :test, Configuration.instance.default_trigger
    end
  end
end
