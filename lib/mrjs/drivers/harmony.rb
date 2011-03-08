module Mrjs
  module Drivers
    class Harmony < Drivers::Base
      attr_accessor :page, :js_adapter

      def initialize(file, err, out)
        @page = Page.new(File.read(file))
        @js_adapter = Adapters.adapters.find {|adapter| page.x(adapter.used?) }

        @page.x(js_setup)
        @page.x(js_adapter.setup)

        @page.wait

        @results = @page.x('$mrjs').groups.map{|group| GroupResult.new(group) }
        @stats = @page.x('$mrjs').stats
      end

      class Page < ::Harmony::Page
        def wait
          Harmony::Page::Window::BASE_RUNTIME.wait
        end
      end

    end
  end
end


