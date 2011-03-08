module Mrjs
  class Runner

    def initialize
      Config.driver = Drivers::Harmony
      Config.formatter = Formatters::BaseFormatter

      at_exit { run(ARGV, $stderr, $stdout) ? exit(0) : exit(1) }
    end

    def run(args, err, out)
      @results, @stats = Config.driver.new(args.first, err, out).run
      out << Config.formatter.new(@results, @stats).summary
    end

  end
end
