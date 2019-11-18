module ReactiveObservers
  module DatabaseAdapters
    class AbstractAdapter
      def initialize(configuration, klasses)
        @configuration = configuration
        @klasses = klasses
      end

      def start_listening
        @klasses.each { |klass| create_listening_job_for klass }
      end

      private

      def create_listening_job_for(klass)
        raise NotImplementedError
      end

      def process_notification_for(data, klass)
        klass.observer_listener_services.each { |service| method(service).call data }
      end
    end
  end
end
