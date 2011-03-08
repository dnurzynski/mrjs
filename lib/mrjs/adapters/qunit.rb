module Mrjs
  module Adapters
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

