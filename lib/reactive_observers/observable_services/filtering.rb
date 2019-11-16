module ReactiveObservers
  module ObservableServices
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

        changed_fields = @options[:diff].keys.map &:to_sym
        observers.select { |observer| observer[:fields].blank? || (observer[:fields] & changed_fields).length.positive? }
      end
    end
  end
end
