module ReactiveObservers
  module DatabaseAdapters
    module Factory
      def initialize(configuration)
        @configuration = configuration
      end

      def initialize_observer_listeners
        collect_database_adapters.each do |database_adapter, klasses|
          case database_adapter
          when 'PostgreSQL'
            PostgreSQLAdapter.new(@configuration, klasses).start_listening
          when 'PostGIS'
            PostgreSQLAdapter.new(@configuration, klasses).start_listening
          else
            raise StandardError, "Reactive observers cannot be run with this database adapter: #{database_adapter}!"
          end
        end
      end

      private

      def collect_database_adapters
        {}.tap do |result|
          @configuration.observed_tables.map do |observed_table|
            klass = observed_table.classify.constantize
            adapter = klass.connection.adapter_name
            result[adapter] = (result[adapter] || []) << klass
          end
        end
      end
    end
  end
end
