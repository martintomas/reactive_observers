require "test_helper"
require 'reactive_observers/database_adapters/postgresql_adapter'

module ReactiveObservers
  module DatabaseAdapters
    class PostgreSQLAdapterTest < ActiveSupport::TestCase
      class ObserverNotified < StandardError; end
      class Observer
        def changed(value, **observer); end
      end

      test '#create_listening_job_for' do
        ActiveSupport::TestCase.switch_to_pg_database
        Topic.active_observers = [ReactiveObservers::Observer::Container.new(Observer, Topic, {})]
        db_adapter = ReactiveObservers::DatabaseAdapters::PostgreSQLAdapter.new(Configuration.instance, [Topic])

        assert_raise(ObserverNotified) do
          Topic.stub :process_observer_notification, ->(*) { raise ObserverNotified } do
            db_adapter.start_listening
            sleep 2
            Topic.create! name: 'third'
            sleep 2
          end
        end

        db_adapter.stop_listening
        Topic.active_observers = []
      end

      test '#stop_listening_job_for' do
        ActiveSupport::TestCase.switch_to_pg_database
        db_adapter = ReactiveObservers::DatabaseAdapters::PostgreSQLAdapter.new(Configuration.instance, [Topic])
        db_adapter.stop_listening
      end
    end
  end
end
