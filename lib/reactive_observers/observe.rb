require 'active_support/concern'

module ReactiveObservers
  module Observe
    extend ActiveSupport::Concern

    included do; end

    class_methods do
      def observe(observed, refine: nil, trigger: Configuration.instance.default_trigger, notify: nil, **options)
        ReactiveObservers::Observer::Container.new self, observed, options.merge(refine: refine, trigger: trigger, notify: notify)
      end
    end

    def observe(observed, refine: nil, trigger: Configuration.instance.default_trigger, notify: nil, **options)
      ReactiveObservers::Observer::Container.new self, observed, options.merge(refine: refine, trigger: trigger, notify: notify)
    end
  end
end
