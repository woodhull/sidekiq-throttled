# frozen_string_literal: true

module Sidekiq
  module Throttled
    # Configuration holder.
    class Configuration
      attr_reader :default_requeue_options

      # Class constructor.
      def initialize
        reset!
      end

      # Reset configuration to defaults.
      #
      # @return [self]
      def reset!
        @inherit_strategies = false
        @default_requeue_options = { with: :enqueue }

        self
      end

      # Instructs throttler to lookup strategies in parent classes, if there's
      # no own strategy:
      #
      #     class FooJob
      #       include Sidekiq::Job
      #       include Sidekiq::Throttled::Job
      #
      #       sidekiq_throttle :concurrency => { :limit => 42 }
      #     end
      #
      #     class BarJob < FooJob
      #     end
      #
      # By default in the example above, `Bar` won't have throttling options.
      # Set this flag to `true` to enable this lookup in initializer, after
      # that `Bar` will use `Foo` throttling bucket.
      def inherit_strategies=(value)
        @inherit_strategies = value ? true : false
      end

      # Whenever throttled workers should inherit parent's strategies or not.
      # Default: `false`.
      #
      # @return [Boolean]
      def inherit_strategies?
        @inherit_strategies
      end

      # Specifies how we should return throttled jobs to the queue so they can be executed later.
      # Expects a hash with keys that may include :with and :to
      # For :with, options are `:enqueue` (put them on the end of the queue) and `:schedule` (schedule for later).
      # For :to, the name of a sidekiq queue should be specified. If none is specified, jobs will by default be
      # requeued to the same queue they were originally enqueued in.
      # Default: {with: `:enqueue`}
      #
      def default_requeue_options=(options)
        requeue_with = options.delete(:with).intern || :enqueue

        @default_requeue_options = options.merge({ with: requeue_with })
      end
    end
  end
end
