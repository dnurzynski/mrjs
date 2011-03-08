require 'rubygems'
require 'harmony'



module Mrjs

  class Runner
    def initialize
      Config.driver = Driver::Harmony
      at_exit { run(ARGV, $stderr, $stdout) ? exit(0) : exit(1) }
    end

    def run(args, err, out)
      @results = Config.driver.new(args.first, err, out).run
      puts @results
    end
  end

  class Config
    class << self
      attr_accessor :driver
    end
  end

  class GroupResult
    attr_accessor :name, :results

    def initialize(group)
      @name, @results = group.name, group.specs.map{|s| ExampleResult.new(s)}
    end
  end

  class ExampleResult
    attr_accessor :name, :assertion_results

    def initialize(spec)
      @name, @assertion_results = spec.name, spec.tests.map{|test| AssertionResult.new(test) }
    end
  end

  class AssertionResult
    attr_accessor :message, :success

    def initialize(assertion)
      @message, @success = assertion.message, assertion.result
    end
  end

  class Driver
    def js_setup
      <<JS
JS
    end

    def run
      @results
    end

    class Harmony < Driver
      attr_accessor :page, :js_adapter
      def initialize(file, err, out)
        @page = Page.new(File.read(file))
        @js_adapter = JsAdapter.adapters.find {|adapter| page.x(adapter.used?) }

        @page.x(js_setup)
        @page.x(js_adapter.setup)

        @page.wait

        @results = @page.x('$mrjs').groups.map{|group| GroupResult.new(group) }.inspect
      end

      class Page < ::Harmony::Page
        def wait
          Harmony::Page::Window::BASE_RUNTIME.wait
        end
      end
    end
  end

  class JsAdapter

    def self.adapters
      @@adapters = [JsAdapter::QUnit]
    end

    class QUnit

      def self.used?
        "(QUnit != 'undefined')"
      end

      def self.setup
        <<JS
JS
      end
    end
  end

end
