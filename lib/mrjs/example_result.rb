module Mrjs
  class ExampleResult
    attr_accessor :name, :assertion_results

    def initialize(spec)
      @name, @assertion_results = spec.name, spec.tests.map{|test| AssertionResult.new(test) }
    end
  end

end
