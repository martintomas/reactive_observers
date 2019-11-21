require "test_helper"
require 'reactive_observers/database_adapters/postgresql_adapter'

module ReactiveObservers
  module DatabaseAdapters
    class PostgreSQLAdapterTest < ActiveSupport::TestCase
      class ObserverNotified < StandardError; end

      test '#create_listening_job_for' do
        ActiveSupport::TestCase.switch_to_pg_database
        Topic.active_observers = [ReactiveObservers::Observer::Container.new(CustomObserver, Topic, {})]
        db_adapter = ReactiveObservers::DatabaseAdapters::PostgreSQLAdapter.new(ReactiveObservers.configuration, [Topic])

        assert_raise(ObserverNotified) do
          Topic.stub :process_observer_notification, ->(*) { raise ObserverNotified } do
            db_adapter.start_listening
            sleep 2.5
            Topic.create! name: 'third'
            sleep 2.5
          end
        end
      end

      test '#stop_listening_job_for' do
        ActiveSupport::TestCase.switch_to_pg_database
        db_adapter = ReactiveObservers::DatabaseAdapters::PostgreSQLAdapter.new(ReactiveObservers.configuration, [Topic])
        db_adapter.stop_listening
      end
    end
  end
end
