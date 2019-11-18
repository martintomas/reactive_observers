module ReactiveObservers
  module Observer
    class ContainerComparator
      def initialize(observer)
        @observer = observer
      end

      def partial?(observer, options)
        @observer.observer == observer &&
          array_compare_of(@observer.fields, options[:fields]) &&
          array_compare_of(@observer.on, options[:on]) &&
          constrain_compare_with(options[:constrain])
      end

      def full?(observer)
        @observer.observer == observer.observer &&
          @observed == observer.observed &&
          array_compare_of(@observer.fields, observer.fields) &&
          array_compare_of(@observer.on, observer.on) &&
          constrain_compare_with(observer.constrain) &&
          @observer.trigger == observer.trigger &&
          @observer.notify == observer.notify &&
          @observer.refine == observer.refine &&
          @observer.only == observer.only
      end

      private

      def array_compare_of(argument, option_value)
        argument.blank? || option_value.blank? || (argument & Array.wrap(option_value)).length.positive?
      end

      def constrain_compare_with(value)
        value = Array.wrap value
        value.blank? || @observer.constrain == value || (@observer.constrain & value).length.positive?
      end
    end
  end
end
