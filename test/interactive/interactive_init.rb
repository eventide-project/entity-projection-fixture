ENV['CONSOLE_DEVICE'] ||= 'stdout'
ENV['LOG_LEVEL'] = 'warn'
ENV['LOG_TAGS'] = 'projection'

ENV['TEST_BENCH_DETAIL'] ||= 'on'

require_relative '../test_init'
