# frozen_string_literal: true

module Cron
  RSpec.describe Parser do
    subject { described_class.call(**params) }

    ERROR_CLASS = described_class::ParseError

    TEST_CASES_VALID = [
      { params: %w[* * * * * foobar], result: { command: 'foobar' } },
      { params: %w[*/15 * * * * foobar], result: { minute: [0, 15, 30, 45], command: 'foobar' } },
      { params: %w[* 1,3,23 * * * foobar], result: { hour: [1, 3, 23], command: 'foobar' } },
      { params: %w[* * 4-15 * * foobar], result: { dom: (4..15).to_a, command: 'foobar' } },
      { params: %w[* * * 9 * foobar], result: { month: [9], command: 'foobar' } },
      { params: %w[* * * * 2 foobar], result: { dow: [2], command: 'foobar' } },
      { params: %w[* * * * 1,7 foobar], result: { dow: [1, 7], command: 'foobar' } },
      { params: %w[* 1 * * 1-3 foobar], result: { hour: [1], dow: [1, 2, 3], command: 'foobar' } }
    ].freeze

    TEST_CASES_INVALID = [
      { params: %w[d * * * * foobar], result: [ERROR_CLASS, /.*/] },
      { params: %w[*/66 * * * * foobar], result: [ERROR_CLASS, /.*/] },
      { params: %w[* 0,3,25 * * * foobar], result: [ERROR_CLASS, /.*/] },
      { params: %w[* * 4-32 * * foobar], result: [ERROR_CLASS, /.*/] },
      { params: %w[* * * 13 * foobar], result: [ERROR_CLASS, /.*/] },
      { params: %w[* * * * 8 foobar], result: [ERROR_CLASS, /.*/] },
      { params: %w[* * * * 1,9 foobar], result: [ERROR_CLASS, /.*/] },
      { params: %w[* 1 * * 3-8 foobar], result: [ERROR_CLASS, /.*/] }
    ].freeze

    describe '.call' do
      context 'with valid cron entries' do
        # MINUTE HOUR DOM MONTH DOW COMMAND
        TEST_CASES_VALID.each do |test_case|
          context test_case[:params].join(', ').to_s do
            let(:params) { Hash[described_class::PARAMETER_OPTIONS.zip(test_case[:params])] }

            it { expect(subject).to include(test_case[:result]) }
          end
        end
      end

      context 'with invalid cron entries' do
        TEST_CASES_INVALID.each do |test_case|
          context test_case[:params].join(', ').to_s do
            let(:params) { Hash[described_class::PARAMETER_OPTIONS.zip(test_case[:params])] }

            it { expect { subject }.to raise_error(*test_case[:result]) }
          end
        end
      end
    end
  end
end
