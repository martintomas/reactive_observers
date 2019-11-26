# frozen_string_literal: true

require 'active_support/concern'
require 'reactive_observers/observer/container'

module ReactiveObservers
  # add observe methods to appropriate class
  #
  # class CustomObserver
  #   include ReactiveObservers::Base
  #
  #   def changed(topic, **observer); end
  # end
  #
  module Base
    extend ActiveSupport::Concern

    class_methods do
      # create class observer for provided active record object or class
      #
      # CustomObserver.observe(:topics) # observer is observing Topic klass
      # CustomObserver.observe(Topic.first) # observer is observing specific topic
      #
      # @param observed [Symbol, Object] observed object or symbol defining specific ActiveRecord class
      # @param refine [Proc] lambda or Proc function defining observed object pre-process before It is sent to observer
      # @param trigger [Proc, Symbol] function that is triggered inside observer during notification
      # @param notify [Proc, Symbol] function that is used to initialize appropriate observer objects
      # @param options [Hash] additional arguments such as: on, only, fields or context
      # @return [ReactiveObservers::Observer::Container] observer
      def observe(observed, refine: nil, trigger: ReactiveObservers.configuration.default_trigger, notify: nil, **options)
        add_observer_to_observable self, observed, options.merge(refine: refine, trigger: trigger, notify: notify)
      end

      # register observer at observed entity
      # @param observer [Class, Object]
      # @param observed [Symbol, Object]
      # @param options [Hash]
      # @return [ReactiveObservers::Observer::Container] observer
      def add_observer_to_observable(observer, observed, options)
        ReactiveObservers::Observer::Container.new(observer, observed, options).tap do |observer_container|
          observer_container.observed_klass.register_observer observer_container
        end
      end
    end

    # create object observer for provided active record object or class
    #
    # CustomObserver.new.observe(:topics) # observer is observing Topic klass
    # CustomObserver.new.observe(Topic.first) # observer is observing specific topic
    #
    # @param observed [Symbol, Object] observed object or symbol defining specific ActiveRecord class
    # @param refine [Proc] lambda or Proc function defining observed object pre-process before It is sent to observer
    # @param trigger [Proc, Symbol] function that is triggered inside observer during notification
    # @param notify [Proc, Symbol] function that is used to initialize appropriate observer objects
    # @param options [Hash] additional arguments such as: on, only, fields or context
    # @return [ReactiveObservers::Observer::Container] observer
    def observe(observed, refine: nil, trigger: ReactiveObservers.configuration.default_trigger, notify: nil, **options)
      self.class.add_observer_to_observable self, observed, options.merge(refine: refine, trigger: trigger, notify: notify)
    end
  end
end
