require 'reactive_observers/database_adapters/abstract_adapter'

module ReactiveObservers
  module DatabaseAdapters
    class PostgreSQLAdapter < AbstractAdapter

      private

      def create_listening_job_for(klass)
        Thread.new do
          klass.connection.execute "LISTEN #{ @configuration.listening_job_name % { table_name: klass.table_name }}"
          loop do
            klass.connection.raw_connection.wait_for_notify do |event, pid, payload|
              data = JSON.parse payload, symbolize_names: true
              process_notification_for data, klass
            end
          end
        end.abort_on_exception = true
      end

      def stop_listening_job_for(klass)
        klass.connection.execute "UNLISTEN #{ @configuration.listening_job_name % { table_name: klass.table_name }}"
      end
    end
  end
end
