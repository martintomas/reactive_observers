require 'singleton'

module ReactiveObservers
  class Configuration
    include Singleton

    attr_accessor :listening_job_name, :observed_tables, :default_trigger

    def initialize
      @listening_job_name = "%{table_name}_notices"
      @observed_tables = []
      @default_trigger = :changed
    end
  end
end
