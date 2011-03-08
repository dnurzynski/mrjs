require 'rubygems'
require 'harmony'



module Mrjs

  class Runner
    def initialize
      Config.driver = Driver::Harmony
      at_exit { run(ARGV, $stderr, $stdout) ? exit(0) : exit(1) }
    end

    def run(args, err, out)
      ExampleGroup.new(args.first, err, out)
    end
  end

  class Config
    class << self
      attr_accessor :driver
    end
  end

  class ExampleGroup

    def initialize(file, err, out)
      Config.driver.new(file, err, out)
    end

  end

  class Driver
    def js_setup
      "$specs = {}"
    end

    class Harmony < Driver
      attr_accessor :page, :js_adapter
      def initialize(file, err, out)
        @page = Page.new(File.read(file))
        @js_adapter = JsAdapter.adapters.find {|adapter| page.x(adapter.used?) }

        @page.x(js_setup)
        @page.x(js_adapter.setup)

        @page.wait

        puts @page.x('$specs')

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

          QUnit.done = function(stats) { $specs['stats'] = stats }
JS
      end
    end
  end

end
