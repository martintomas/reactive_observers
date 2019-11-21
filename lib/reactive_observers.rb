require 'reactive_observers/version'
require 'reactive_observers/configuration'
require 'reactive_observers/base'
require 'reactive_observers/observable/base'
require 'reactive_observers/database_adapters/factory'

require 'active_record'

module ReactiveObservers
  class Error < StandardError; end

  mattr_accessor :configuration, default: Configuration.new

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
    DatabaseAdapters::Factory.new(configuration).initialize_observer_listeners
  end
end

class ActiveRecord::Base
  include ReactiveObservers::Observable::Base
end
