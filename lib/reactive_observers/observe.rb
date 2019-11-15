module ReactiveObservers
  class Observe
    extend ActiveSupport::Concern

    included do; end

    class_methods do
      def observe(active_record, refine:, trigger: nil, **options)
        klass = active_record.classify.constantize
        raise ArgumentError, "Class #{klass.name} is missing required observed method #{trigger}" unless klass.method_defined? trigger

        klass.register_klass_observer options.merge(klass: self, refine: refine, trigger: trigger || Configuration.instance.default_trigger)
      end
    end
  end
end
