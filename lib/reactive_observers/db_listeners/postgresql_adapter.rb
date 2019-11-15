module ReactiveObservers
  module DbListeners
    class PostgresqlAdapter
      def initialize(configuration)
        @configuration = configuration
      end

      def start_listening_job
        Rails.logger.debug  "Postgresql adapter listening_job started"
        Thread.new do
          Rails.logger.debug  "listening_job running on #{@configuration.listening_job_name}"
          ActiveRecord::Base.connection.execute "LISTEN #{@configuration.listening_job_name}"
          loop do
            ActiveRecord::Base.connection.raw_connection.wait_for_notify do |event, pid, payload|
              data = JSON.parse payload, symbolize_names: true
              Rails.logger.debug "postgres #{event.inspect}, pid: #{pid.inspect}, data: #{data.inspect}"
              process_notification_for data
            end
          end
        end.abort_on_exception = true
      end

      def process_notification_for(data)
        klass = data[:table].classify.constantize

        klass.listener_services.each { |service| method(service).call data }
      end
    end
  end
end
