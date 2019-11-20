require 'reactive_observers/observer/container_validator'
require 'reactive_observers/observer/container_comparator'

module ReactiveObservers
  module Observer
    class Container

      attr_accessor :observer, :observed
      attr_accessor :trigger, :notify, :refine, :context
      attr_accessor :fields, :on, :only, :constrain

      def initialize(observer, observed, options)
        @observer = observer
        @observed = observed.is_a?(Symbol) ? observed.to_s.classify.constantize : observed
        @on = Array.wrap options[:on]
        @fields = Array.wrap options[:fields]
        @only = options[:only]
        @trigger = options[:trigger] || Configuration.instance.default_trigger
        @notify = options[:notify]
        @refine = options[:refine]
        @context = options[:context]
        ReactiveObservers::Observer::ContainerValidator.new(self).run_validations!
        @constrain = load_observer_constrains
      end

      def compare
        ReactiveObservers::Observer::ContainerComparator.new(self)
      end

      def klass_observer?
        @observer.is_a? Class
      end

      def klass_observed?
        @observed.is_a? Class
      end

      def observer_klass
        return @observer if klass_observer?

        @observer.class
      end

      def observed_klass
        return @observed if klass_observed?

        @observed.class
      end

      def to_h
        { observer: @observer, observed: @observed, fields: @fields, on: @on, only: @only, constrain: @constrain,
          trigger: @trigger, refine: @refine, notify: @notify, context: @context}
      end

      private

      def load_observer_constrains
        return [] if @observed.is_a?(Class)

        [@observed.id]
      end
    end
  end
end
