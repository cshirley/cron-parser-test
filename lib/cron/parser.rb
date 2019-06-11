# frozen_string_literal: true

module Cron
  # Service Object which expands the CRON tokens into a hash
  class Parser
    ParseError = Class.new(StandardError)

    PARAMETER_OPTIONS = %i[minute hour dom month dow command].freeze

    # Expands the CRON tokens
    #
    # all parameters accept the base CRON tokens:
    #   *, */d+, d+, (d,d)+
    #
    # @param [String] minute - minute of hour 0-59
    # @param [String] hour - hour of day 0-23
    # @param [String] dom - day of month 1-31
    # @param [String] month - month number 1-12
    # @param [String] dow - Day of week number
    def self.call(minute:, hour:, dom:, month:, dow:, command:)
      new(
        minute: minute, hour: hour, dom: dom, month: month, dow: dow, command: command
      ).call
    end

    # Parses the input
    #
    # @return [Hash] - expand values with the following keys:
    #   minute: [Integer]
    #   hour: [Integer]
    #   dom: [Integer]
    #   month: [Integer]
    #   dow: [Integer]
    #   command: [String]
    def call
      options.each_with_object({}) do |(name, value), result|
        result[name] = parse(name, value)
      end
    end

    private

    REGEX_RANGE_VALIDATOR = %r{(-|,|\/)}.freeze
    REGEX_VALUE_VALIDATOR = %r{^((\*|\d+)(\/\d+){0,1})|(\d+-\d+)|(\d+(,\d+)+)$}.freeze

    TIME_OPTIONS = {
      minute: { min: 0, max: 59 },
      hour: { min: 0, max: 23 },
      dom: { min: 1, max: 31 },
      dow: { min: 1, max: 7 },
      month: { min: 1, max: 12 }
    }.freeze

    SUB_RANGE = '-'
    STEP_RANGE = '/'
    ITEMS_RANGE = ','
    SINGLE_ITEM_RANGE = '*'

    RANGE_DISPATCHER = { SUB_RANGE => :build_sub_range,
                         STEP_RANGE => :build_step_range,
                         ITEMS_RANGE => :build_items_range,
                         SINGLE_ITEM_RANGE => :build_item_range }.freeze

    attr_reader :options

    def initialize(**opts)
      @options = opts
    end

    def parse(name, value)
      return value if name == :command

      raise_parse_error(name, value) unless value.match?(REGEX_VALUE_VALIDATOR)

      range_separator = extract_range_separator(value)
      send(RANGE_DISPATCHER[range_separator], name, value)
    end

    def extract_range_separator(value)
      match = value.match(REGEX_RANGE_VALIDATOR)
      match ? match[0] : SINGLE_ITEM_RANGE
    end

    def fetch_option_value(option_name, key)
      TIME_OPTIONS[option_name][key]
    end

    def build_sub_range(name, value)
      start_of_range, end_of_range = value.split(SUB_RANGE).map(&:to_i)
      start_of_range = start_of_range == '*' ? fetch_option_value(name, :min) : start_of_range

      unless range_valid?(start_of_range, end_of_range,
                          fetch_option_value(name, :min),
                          fetch_option_value(name, :max))
        raise_parse_error(name, value)
      end

      build_range(start_of_range, end_of_range)
    end

    def build_step_range(name, value)
      start_of_range, range_step = value.split(STEP_RANGE).map(&:to_i)
      start_of_range = start_of_range == '*' ? fetch_option_value(name, :min) : start_of_range

      unless range_valid?(start_of_range, fetch_option_value(name, :max),
                          fetch_option_value(name, :min),
                          fetch_option_value(name, :max), range_step)
        raise_parse_error(name, value)
      end

      build_range(start_of_range, fetch_option_value(name, :max), range_step)
    end

    def build_items_range(name, value)
      values = value.split(ITEMS_RANGE).map(&:to_i)
      min = fetch_option_value(name, :min)
      max = fetch_option_value(name, :max)

      raise_parse_error(name, value) unless values.collect { |v| v >= min && v <= max }.all?

      values
    end

    def build_item_range(name, value)
      if value != SINGLE_ITEM_RANGE &&
         (value.to_i < fetch_option_value(name, :min) ||
          value.to_i > fetch_option_value(name, :max))
        raise_parse_error(name, value)
      end

      return [value.to_i] unless value == SINGLE_ITEM_RANGE

      build_range(fetch_option_value(name, :min), fetch_option_value(name, :max))
    end

    def build_range(start, stop, step = 1)
      (start..stop).step(step).to_a
    end

    def range_valid?(start, stop, min, max, step = 1)
      start >= min && start < max &&
        stop > min && stop <= max && stop > start &&
        step.positive? && step < max
    end

    def raise_parse_error(name, value)
      raise ParseError, "#{name} has invalid value: #{value}"
    end
  end
end
