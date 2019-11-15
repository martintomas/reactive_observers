module ReactiveObservers
  module DbListeners
    module SimpleFactory
      def initialize(configuration)
        @configuration = configuration
      end

      def initialize_db_listeners
        collect_databases.each do |database|
          case database
          when :postgresql
            PostgresqlAdapter.new(@configuration).start_listening_job
          else
            raise StandardError, 'Reactive observers cannot be run with current database!'
          end
        end
      end

      def collect_databases
        @configuration.observed_tables.map do |observed_table|
          observed_table.classify.constantize.connection.current_database
        end.uniq
      end
    end
  end
end
