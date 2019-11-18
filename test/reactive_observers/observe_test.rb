require "test_helper"

module ReactiveObservers
  module ObservableServices
    class ObserveTest < ActiveSupport::TestCase
      class Observer
        include ReactiveObservers::Observe

        def changed; end
      end

      test '.observe - register all records' do
        Observer.observe :topics
      end

      test '.observe - register specific record' do
        Observer.observe topics(:first)
      end

      test '#observe - register all records' do
        Observer.new.observe :topics
      end

      test '#observe - register specific record' do
        Observer.new.observe topics(:first)
      end
    end
  end
end
