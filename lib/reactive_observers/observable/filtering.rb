module ReactiveObservers
  module Observable
    class Filtering
      def initialize(observers, action, options)
        @observers = observers
        @action = action
        @options = options
      end

      def perform
        @observers.then { |observers| filter_action observers }
                  .then { |observers| filter_fields observers }
      end

      private

      def filter_action(observers)
        observers.select { |observer| observer[:on].blank? || observer[:on].include?(@action) }
      end

      def filter_fields(observers)
        return observers unless @action == :update && @options[:diff].present?

        observers.select { |observer| observer[:fields].blank? || (observer[:fields] & @options[:diff].keys).positive? }
      end
    end
  end
end
