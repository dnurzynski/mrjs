module Mrjs
  module Drivers
    class Base
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
        [@results, @stats]
      end

    end
  end
end
