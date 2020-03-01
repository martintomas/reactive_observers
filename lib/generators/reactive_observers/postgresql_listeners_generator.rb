# frozen_string_literal: true

require "rails/generators/active_record"

module ReactiveObservers
  class PostgresqlListenersGenerator < Rails::Generators::Base
    include ActiveRecord::Generators::Migration
    source_root File.expand_path('templates', __dir__)

    argument :tables, type: :array, default: []

    desc 'This generator creates migration with database listeners for postgresql database'

    def copy_install_file
      migration_template 'postgresql_listeners_migration.rb', File.join(db_migrate_path, "create_postgresql_listeners.rb")
    end

    def table_listeners
      format ReactiveObservers.configuration.listening_job_name, table_name: ''
    end
  end
end
