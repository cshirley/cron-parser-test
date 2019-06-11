# frozen_string_literal: true

require_relative './cron/parser.rb'
require_relative './cron/formatter.rb'

class Client
  # @param [Array<String>] args - single argument array
  # @param [String] caller - program/script name
  def initialize(args, caller = $PROGRAM_NAME)
    @caller = caller
    @args = args
  end

  # Parses the CRON input arguments and returns a space tabulated string
  #
  # @raise Cron::Parser::ParserError
  #
  # @return [String] space tabulated and expanded CRON task
  def call
    return "Usage #{@caller} MINUTE HOUR DOM DOW MONTH COMMAND" unless args.count == 6

    params = Hash[::Cron::Parser::PARAMETER_OPTIONS.zip(args)]

    ::Cron::Formatter.call(
      ::Cron::Parser.call(params)
    )
  end

  private

  attr_reader :args, :caller
end