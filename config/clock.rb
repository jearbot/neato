require 'clockwork'
require_relative './boot'
require_relative './environment'

module Clockwork
  configure do |config|
    config[:sleep_timeout] = 10
  end

  every(1.day, 'RunNeatoJob', at: '04:00') do
    RunNeatoJob.perform_now
  end

  every(1.day, 'RefreshTokenJob', at: '09:00') do
    RefreshTokenJob.perform_now
  end
end
