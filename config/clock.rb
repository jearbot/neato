require 'clockwork'
require_relative './boot'
require_relative './environment'

module Clockwork
  configure do |config|
    config[:sleep_timeout] = 10
  end

  every(1.day, 'RunNeatoJob', at: '08:30', tz: 'America/Chicago') do
    RunNeatoJob.perform_now
  end

  every(1.day, 'RefreshTokenJob', at: '19:00', tz: 'America/Chicago') do
    RefreshTokenJob.perform_now
  end
end
