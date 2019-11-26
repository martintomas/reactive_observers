# frozen_string_literal: true

module ReactiveObservers
  class Configuration

    attr_accessor :listening_job_name, :observed_tables, :default_trigger

    def initialize
      reset!
    end

    def reset!
      @listening_job_name = "%{table_name}_notices" # trigger listens for these type of notices
      @observed_tables = [] # these tables are observed at database level
      @default_trigger = :changed # default name of method that is called inside observer during notification
    end
  end
end
