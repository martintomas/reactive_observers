require 'active_support/concern'
require 'reactive_observers/observer/container'

module ReactiveObservers
  module Base
    extend ActiveSupport::Concern

    included do; end

    class_methods do
      def observe(observed, refine: nil, trigger: ReactiveObservers.configuration.default_trigger, notify: nil, **options)
        add_observer_to_observable self, observed, options.merge(refine: refine, trigger: trigger, notify: notify)
      end

      def add_observer_to_observable(observer, observed, options)
        ReactiveObservers::Observer::Container.new(observer, observed, options).tap do |observer_container|
          observer_container.observed_klass.register_observer observer_container
        end
      end
    end

    def observe(observed, refine: nil, trigger: ReactiveObservers.configuration.default_trigger, notify: nil, **options)
      self.class.add_observer_to_observable self, observed, options.merge(refine: refine, trigger: trigger, notify: notify)
    end
  end
end
