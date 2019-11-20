require "test_helper"
require 'reactive_observers/database_adapters/factory'
require 'reactive_observers/database_adapters/postgresql_adapter'

module ReactiveObservers
  module DatabaseAdapters
    class FactoryTest < ActiveSupport::TestCase
      setup do
        Configuration.instance.reset!
      end

      teardown do
        Configuration.instance.reset!
      end

      test '#initialize_observer_listeners - postgresql' do
        ActiveSupport::TestCase.switch_to_pg_database

        verify_listening_start!(adapter: ReactiveObservers::DatabaseAdapters::PostgreSQLAdapter) do
          ReactiveObservers::DatabaseAdapters::Factory.new(Configuration.instance).initialize_observer_listeners
        end
      end

      test '#initialize_observer_listeners - postgis' do
        ActiveSupport::TestCase.switch_to_postgis_database

        verify_listening_start!(adapter: ReactiveObservers::DatabaseAdapters::PostgreSQLAdapter) do
          ReactiveObservers::DatabaseAdapters::Factory.new(Configuration.instance).initialize_observer_listeners
        end
      end

      test '#initialize_observer_listeners - sqlite' do
        ActiveSupport::TestCase.switch_to_sqlite_database

        exception = assert_raise(StandardError) do
          Configuration.instance.observed_tables = [:topics]
          ReactiveObservers::DatabaseAdapters::Factory.new(Configuration.instance).initialize_observer_listeners
        end
        assert_equal 'Reactive observers cannot be run with this database adapter: SQLite!', exception.message
      end

      private

      def verify_listening_start!(adapter: ReactiveObservers::DatabaseAdapters::PostgreSQLAdapter)
        Configuration.instance.observed_tables = [:topics]
        listening_adapter_mock = Minitest::Mock.new
        listening_adapter_mock.expect :start_listening, true
        adapter_stub = Proc.new do |*args|
          assert_equal Configuration.instance, args[0]
          assert_equal [Topic], args[1]
          listening_adapter_mock
        end

        adapter.stub :new, adapter_stub do
          yield
        end

        listening_adapter_mock.verify
      end
    end
  end
end
