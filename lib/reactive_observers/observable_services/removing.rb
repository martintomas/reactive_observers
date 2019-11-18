module ReactiveObservers
  module ObservableServices
    class Removing
      REQUIRED_FIELDS = %i[klass object].freeze

      def initialize(active_observers, removing_options)
        @active_observers = active_observers
        @removing_options = removing_options
      end

      def perform
        collect_removed_observers.each { |deleted_observer| @active_observers.delete deleted_observer }
        @active_observers
      end

      private

      def collect_removed_observers
        @active_observers.select do |observer|
          remove = true
          @removing_options.each do |key, value|
            next if observer[key].blank? && !REQUIRED_FIELDS.include?(key)
            next if observer[key].is_a?(Array) && (Array.wrap(value) & observer[key]).length.positive?
            next if observer[key] == value

            break remove = false
          end
          remove
        end
      end
    end
  end
end
