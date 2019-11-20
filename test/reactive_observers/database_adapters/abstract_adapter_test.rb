require "test_helper"
require 'reactive_observers/database_adapters/abstract_adapter'

module ReactiveObservers
  module DatabaseAdapters
    class AbstractAdapterTest < ActiveSupport::TestCase
      test '#start_listening' do
        assert_raise(NotImplementedError) do
          ReactiveObservers::DatabaseAdapters::AbstractAdapter.new(Configuration.instance, [Topic]).start_listening
        end
      end

      test '#stop_listening' do
        assert_raise(NotImplementedError) do
          ReactiveObservers::DatabaseAdapters::AbstractAdapter.new(Configuration.instance, [Topic]).stop_listening
        end
      end
    end
  end
end
