module ReactiveObservers
  module Observable
    class Removing
      REQUIRED_FIELDS = %i[klass object].freeze

      def initialize(active_observers, observer, removing_options)
        @active_observers = active_observers
        @observer = observer
        @removing_options = removing_options
      end

      def perform
        @active_observers.delete_if do |active_observer|
          active_observer.compare.partial? @observer, @removing_options
        end
      end
    end
  end
end
