require 'reactive_observers/version'
require 'reactive_observers/configuration'
require 'reactive_observers/base'
require 'reactive_observers/observable/base'
require 'reactive_observers/database_adapters/factory'

require 'active_record'

module ReactiveObservers
  class Error < StandardError; end

  def self.configure
    self.configuration ||= Configuration.instance
    yield(configuration)
    DatabaseAdapters::Factory.new(configuration).initialize_observer_listeners
  end
end

class ActiveRecord::Base
  include ReactiveObservers::Observable::Base
end
