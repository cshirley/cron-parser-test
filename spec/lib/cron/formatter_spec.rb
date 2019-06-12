# frozen_string_literal: true

module Cron
  RSpec.describe Formatter do
    subject { described_class.call(params) }

    describe '.call' do
      context 'with valid result' do
        let(:params) do
          { minute: [1], hour: [2],
            dom: [3], month: [4], dow: [5, 6],
            command: 'test' }
        end

        it 'renders minute in string' do
          expect(subject).to match(/minute\s+1\n/)
        end

        it 'renders hour in string' do
          expect(subject).to match(/hour\s+2\n/)
        end

        it 'renders day of month in string' do
          expect(subject).to match(/day of month\s+3\n/)
        end

        it 'renders month in string' do
          expect(subject).to match(/month\s+4\n/)
        end

        it 'renders day of week in string' do
          expect(subject).to match(/day of week\s+5 6\n/)
        end

        it 'renders command in string' do
          expect(subject).to match(/command\s+test\n/)
        end
      end
    end
  end
end
