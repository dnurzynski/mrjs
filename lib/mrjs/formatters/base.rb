class Formatters
  class BaseFormatter
    attr_accessor :group_results, :level, :out

    def initialize(group_results, stats)
      @out = ""
      @level = 0
      @group_results = group_results
      @stats = stats
    end

    def group_result(group)
      @level = 0
      white group.name
      group.results.each {|result| example_result(result) }
    end

    def example_result(example)
      @level = 1
      white example.name
      example.assertion_results.each {|assertion| assertion_result(assertion)}
    end

    def assertion_result(assertion)
      @level = 2
      assertion.success ? green(assertion.message) : red(assertion.message)
    end

    def stats
      white "\nStats:"
      send (@stats.failed > 0 ? :red : :green),  "Total:   #{@stats.total}"
      green "Passed:  #{@stats.passed}"
      send (@stats.failed > 0 ? :red : :green),  "Failed:  #{@stats.failed}"
    end

    def summary
      @group_results.each{|group| group_result(group)}
      stats
      @out
    end

    def green(text)
      show text, 32
    end

    def white(text)
      show text, 37
    end

    def red(text)
      show text, 31
    end

    def show(text, color = nil)
      text = "\e[#{color}m#{text}\e[0m" if color
      @out << indentation + text.to_s + "\n"
    end

    def indentation
      "  " * @level
    end
  end
end


