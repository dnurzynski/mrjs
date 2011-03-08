require 'rubygems'
require 'harmony'

module Mrjs

  class Runner
    def initialize
      Config.driver = Driver::Harmony
      Config.formatter = Formatters::BaseFormatter

      at_exit { run(ARGV, $stderr, $stdout) ? exit(0) : exit(1) }
    end

    def run(args, err, out)
      @results = Config.driver.new(args.first, err, out).run
      out << Config.formatter.new(@results).summary
    end
  end

  class Config
    class << self
      attr_accessor :driver, :formatter
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

  class Formatters
    class BaseFormatter
      attr_accessor :group_results, :level, :out

      def initialize(group_results)
        @out = ""
        @group_results, @level = group_results, 0
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

      def summary
        @group_results.each{|group| group_result(group)}
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

  class Driver
    def js_setup
      <<JS
        $mrjs = {
          stats: {},
          groups: [],

          addGroup: function(groupName)
          {
            $mrjs.groups.push(
            {
              name: groupName.name,
              specs: []
            })

          },
          currentGroup: function()
          {
            return $mrjs.groups[$mrjs.groups.length - 1]
          },
          currentSpec: function()
          {
            return $mrjs.currentGroup().specs[$mrjs.currentGroup().specs.length - 1]
          },

          addSpec: function(spec)
          {
            $mrjs.currentGroup().specs.push(spec)
            $mrjs.currentSpec()['tests'] = []
          },
          addLog: function(log)
          {
            $mrjs.currentSpec().tests.push(log)
          }
        }
        $mrjs.addGroup({ name: 'Global' })
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

        @results = @page.x('$mrjs').groups.map{|group| GroupResult.new(group) }
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
          QUnit.done = function(stats) { $mrjs['stats'] = stats }

          QUnit.moduleStart = function(name)
          {
            $mrjs.addGroup(name)
          }

          QUnit.moduleDone = function(name)
          {
          }

          QUnit.testStart = function(name)
          {
            $mrjs.addSpec(name)
          }

          QUnit.log = function(result)
          {
            $mrjs.addLog(result)
          }
JS
      end
    end
  end

end
