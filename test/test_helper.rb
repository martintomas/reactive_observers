$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "reactive_observers"
require 'yaml'
require 'active_record'
require 'active_support'

require "minitest/autorun"
require 'minitest/reporters'

Minitest::Reporters.use!

class Rails
  class << self
    attr_reader :env, :logger, :configuration
  end

  @env = 'test'
  @logger = Logger.new STDOUT
  @configuration = OpenStruct.new( x: OpenStruct.new(reactive_observers: OpenStruct.new(at_once: 2)))
end

module ActiveSupport
  class TestCase
    include ActiveRecord::TestFixtures

    self.fixture_path = File.path 'test/fixtures'
    fixtures %i[topics comments]

    def self.prepare_pg_database
      puts 'Preparing PostgreSQL database'

      require 'pg'

      ActiveRecord::Base.configurations = YAML.load File.read('test/fixtures/files/postgresql/database.yml')
      ActiveRecord::Tasks::DatabaseTasks.drop_current
      ActiveRecord::Tasks::DatabaseTasks.create_current
      ActiveRecord::Migrator.migrations_paths = [File.path("test/fixtures/files/postgresql/migrations")]
      ActiveRecord::Tasks::DatabaseTasks.migrate
    end
  end
end

ActiveSupport::TestCase.prepare_pg_database

class Topic < ActiveRecord::Base
  include ReactiveObservers::Observable

  has_many :comments, dependent: :destroy
end

class Comment < ActiveRecord::Base
  include ReactiveObservers::Observable

  belongs_to :topic
end
