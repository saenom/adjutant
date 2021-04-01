module Interactor
  class Interrupt < StandardError
    attr_reader :errors

    def initialize(errors)
      super

      @errors = errors
    end
  end
end
