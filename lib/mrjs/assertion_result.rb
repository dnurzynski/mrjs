module Mrjs
  class AssertionResult
    attr_accessor :message, :success

    def initialize(assertion)
      @message, @success = assertion.message, assertion.result
    end
  end

end
