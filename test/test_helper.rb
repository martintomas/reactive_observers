$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require 'simplecov'
SimpleCov.start do
  add_filter %w[/bin/ /test/ /lib/generators/ Gemfile Rakefile reactive_observers.gemspec]
end

require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov

require "reactive_observers"
require 'yaml'
require 'active_record'
require 'active_support'

require "minitest/autorun"
require 'minitest/reporters'

require 'pg'
require 'activerecord-postgis-adapter'
require 'sqlite3'

Minitest::Reporters.use!

class Rails
  class << self
    attr_reader :env, :logger, :configuration, :root
  end

  @env = 'test'
  @root = __dir__
  @logger = Logger.new STDOUT
  @configuration = OpenStruct.new( x: OpenStruct.new(reactive_observers: OpenStruct.new(at_once: 2)))
end

module ActiveSupport
  class TestCase
    include ActiveRecord::TestFixtures

    class << self
      attr_accessor :active_db
    end

    self.fixture_path = File.path 'test/fixtures'
    self.use_transactional_tests = false
    parallelize workers: 1
    fixtures %i[topics comments]

    def self.switch_to_pg_database
      switch_db_to 'postgresql'
    end

    def self.switch_to_postgis_database
      switch_db_to 'postgis'
    end

    def self.switch_to_sqlite_database
      switch_db_to 'sqlite3'
    end

    def self.switch_db_to(db_name)
      return if active_db == db_name

      puts "Preparing #{db_name} database"
      self.active_db = db_name

      ActiveRecord::Base.configurations = YAML.load File.read("test/fixtures/files/#{active_db}/database.yml")
      drop_current_database
      ActiveRecord::Tasks::DatabaseTasks.create_current
      ActiveRecord::Migrator.migrations_paths = [File.path("test/fixtures/files/#{active_db}/migrations")]
      ActiveRecord::Tasks::DatabaseTasks.migrate
    end

    def self.drop_current_database
      ActiveRecord::Tasks::DatabaseTasks.drop_current
    rescue ActiveRecord::StatementInvalid, Errno::EBADF => e # db can return errors during drop
      puts e.inspect
    end

    setup do
      Topic.active_observers = []
      Comment.active_observers = []
      ReactiveObservers.configuration.reset!
    end

    teardown do
      Topic.active_observers = []
      Comment.active_observers = []
      ReactiveObservers.configuration.reset!
    end
  end
end

ActiveSupport::TestCase.switch_to_pg_database

class Topic < ActiveRecord::Base
  include ReactiveObservers::Observable::Base

  has_many :comments, dependent: :destroy
end

class Comment < ActiveRecord::Base
  include ReactiveObservers::Observable::Base

  belongs_to :topic
end

class CustomObserver
  include ReactiveObservers::Base

  def self.init(value); end

  def changed(value, **observer); end
end
