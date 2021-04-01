module Interactor
  class Simple
    attr_accessor :raw_input, :errors, :result, :input

    class << self
      def run!(*input)
        new.tap { |v| v.perform!(*input) }
      end
    end

    def execute
      raise NotImplementedError, 'Must be implemented in children'
    end

    def success?
      errors.blank?
    end

    def failed?
      !success?
    end

    def fail!(errors)
      raise ::Interactor::Interrupt, errors
    end

    def perform!(*args)
      self.result = execute(*args)
    rescue ::Interactor::Interrupt => e
      self.errors = (errors || {}).merge(e.errors)
    end

    def on_success
      yield result if block_given? && success?
      self
    end

    def on_failure
      yield errors if block_given? && !success?
      self
    end
  end
end
