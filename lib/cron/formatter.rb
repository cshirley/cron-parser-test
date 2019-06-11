# frozen_string_literal: true

module Cron
  class Formatter
    TAB = 4

    TRANSCODES = { minute: 'minute',
                   hour: 'hour',
                   dom: 'day of month',
                   month: 'month',
                   dow: 'day of week',
                   command: 'command' }.freeze

    PADDING = TRANSCODES.values.map(&:length).max + TAB

    class << self
      # Formats Cron::Parser.call results
      #
      # @return [String]
      def call(result = {})
        result.map do |name, value|
          TRANSCODES[name].ljust(PADDING, ' ') + format_value(value)
        end.join("\n")
      end

      private

      def format_value(value)
        value.respond_to?(:join) ? value.join(' ') : value
      end
    end
  end
end
