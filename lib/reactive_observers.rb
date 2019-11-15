require 'reactive_observers/version'
require 'reactive_observers/configuration'
require 'reactive_observers/observe'
require 'reactive_observers/observable'
require 'reactive_observers/db_listeners/simple_factory'

module ReactiveObservers
  class Error < StandardError; end

  def self.configure
    self.configuration ||= Configuration.instance
    yield(configuration)
    DbListener::SimpleFactory.new(configuration).initialize_db_listeners
  end
end

class ActiveRecord::Base
  include ReactiveObservers::Observable
end
