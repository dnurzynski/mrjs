module Mrjs
  class GroupResult
    attr_accessor :name, :results

    def initialize(group)
      @name, @results = group.name, group.specs.map{|s| ExampleResult.new(s)}
    end
  end
end
